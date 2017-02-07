# frozen_string_literal: true
require 'fluent/output'
require 'uri'
require 'net/http'
require 'json'

# Fluentd
module Fluent
  # The out_http buffered output plugin sends event records via HTTP.
  class HTTPOutput < BufferedOutput
    Fluent::Plugin.register_output('http', self)

    desc 'URL to send event records to'
    config_param :url, :string

    desc 'Acceptable response status codes'
    config_param :accept_status_code, :array, default: ['200']

    desc 'Authorization token'
    config_param :authorization_token, :string, default: nil

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

      @url = validate_url(url)
      @accept_status_code = validate_accept_status_code(accept_status_code)
      @authorization_token = validate_authorization_token(authorization_token)
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

    # Sends the event records
    #
    # @param chunk [#msgpack_each] buffer chunk that includes multiple
    #   formatted events
    # @return void
    def write(chunk)
      records = []
      chunk.msgpack_each { |_tag, _time, record| records << record }

      post_records = post_records_request(records)
      response = http.request(post_records)

      return if accept_status_code.include?(response.code)
      raise ResponseError.error(post_records, response)
    end

    private

    attr_reader :http

    JSON_MIME_TYPE = 'application/json'
    USER_AGENT = 'FluentPluginHTTP'

    private_constant :USER_AGENT, :JSON_MIME_TYPE

    def post_records_request(records)
      Net::HTTP::Post.new(url).tap do |request|
        request.body = JSON.dump(records)
        request.content_type = JSON_MIME_TYPE
        request['User-Agent'] = USER_AGENT

        if authorization_token
          request['Authorization'] = "Token token=#{authorization_token}"
        end
      end
    end

    def validate_url(test_url)
      url = URI(test_url)
      return url if url.scheme == 'http' || url.scheme == 'https'

      raise Fluent::ConfigError,
            "Unacceptable URL scheme, expected HTTP or HTTPs: #{test_url}"
    rescue URI::InvalidURIError => invalid_uri_error
      raise Fluent::ConfigError, invalid_uri_error
    end

    def validate_accept_status_code(status_codes)
      if !status_codes.empty? && status_codes.all?(&method(:http_status_code?))
        return status_codes
      end

      raise Fluent::ConfigError, "Invalid status codes: #{status_codes.inspect}"
    end

    HTTP_STATUS_CODE_RANGE = (100...600).freeze
    private_constant :HTTP_STATUS_CODE_RANGE

    def http_status_code?(code)
      HTTP_STATUS_CODE_RANGE.cover?(code.to_i)
    end

    def validate_authorization_token(value)
      return value if value.nil?
      return value unless value.empty?

      raise Fluent::ConfigError, "Invalid authorization token: #{value.inspect}"
    end
  end
end
