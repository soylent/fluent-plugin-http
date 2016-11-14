# frozen_string_literal: true
require 'fluent/output'
require 'uri'
require 'net/http'

# Fluentd
module Fluent
  # The out_http buffered output plugin sends event records via HTTP.
  class HTTPOutput < BufferedOutput
    Fluent::Plugin.register_output('http', self)

    desc 'The URL to send event records to'
    config_param :url, :string

    def initialize
      require 'fluent/plugin/http/error'

      super
    end

    # Configures the plugin
    #
    # @param conf [Hash] the plugin configuration
    # @return void
    def configure(conf)
      super

      @url = URI(conf.fetch('url'))

      unless @url.scheme == 'http' || @url.scheme == 'https'
        raise Fluent::ConfigError,
              "Unacceptable URL scheme, expected HTTP or HTTPs: #{@url}"
      end
    rescue URI::InvalidURIError => invalid_uri_error
      raise Fluent::ConfigError, invalid_uri_error
    end

    # Hook method that is called at the startup
    #
    # @return void
    def start
      super

      is_https = url.scheme == 'https'
      @http = Net::HTTP.start(url.host, url.port, use_ssl: is_https)
    end

    # Hook method that is called at the shutdown
    #
    # @return void
    def shutdown
      super

      http.finish
    end

    # Serializes the event
    #
    # @param tag [#to_msgpack] the event tag
    # @param time [#to_msgpack] the event timestamp
    # @param record [#to_msgpack] the event record
    # @return [String] serialized event
    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    SUCCESSFUL_RESPONSE_CODE_PREFIX = '2'
    USER_AGENT = 'FluentPluginHTTP'
    private_constant :SUCCESSFUL_RESPONSE_CODE_PREFIX, :USER_AGENT

    # Sends the event records
    #
    # @param chunk [#msgpack_each] buffer chunk that includes multiple
    #   formatted events
    # @return void
    def write(chunk)
      chunk.msgpack_each do |_tag, _time, record|
        post_record = Net::HTTP::Post.new(url)
        post_record.set_form_data(record)
        post_record['User-Agent'] = USER_AGENT

        response = http.request(post_record)

        unless response.code.start_with?(SUCCESSFUL_RESPONSE_CODE_PREFIX)
          raise ResponseError.error(post_record, response)
        end
      end
    end

    private

    attr_reader :http
  end
end
