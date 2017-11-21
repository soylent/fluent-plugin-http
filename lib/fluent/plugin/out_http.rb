# frozen_string_literal: true

require 'fluent/output'
require 'net/http'
require 'oj'
require 'uri'

# Fluentd
module Fluent
  # The out_http buffered output plugin sends event records via HTTP.
  class HTTPOutput < ObjectBufferedOutput
    Fluent::Plugin.register_output('http', self)

    desc 'URL to send event records to'
    config_param :url, :string

    desc 'Acceptable response status codes'
    config_param :accept_status_code, :array, default: ['200']

    desc 'Authorization token'
    config_param :authorization_token, :string, default: nil, secret: true

    desc 'Keep-alive timeout'
    config_param :keep_alive_timeout, :float, default: 60.0

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
      @keep_alive_timeout = validate_keep_alive_timeout(keep_alive_timeout)
    end

    # Hook method that is called at the shutdown
    #
    # @return void
    def shutdown
      super

      disconnect
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
      return if chunk.empty?

      records = []

      chunk.msgpack_each do |tag_time_record|
        records << (_record = tag_time_record.last)
      end

      post_records = post_records_request(records)
      response = connect.request(post_records)

      return if accept_status_code.include?(response.code)
      raise ResponseError.error(post_records, response)
    end

    private

    JSON_MIME_TYPE = 'application/json'.freeze
    private_constant :JSON_MIME_TYPE

    USER_AGENT = 'FluentPluginHTTP'.freeze
    private_constant :USER_AGENT

    HTTPS_SCHEME = 'https'.freeze
    private_constant :HTTPS_SCHEME

    def connect
      @http ||= Net::HTTP.start(
        url.host,
        url.port,
        use_ssl: url.scheme == HTTPS_SCHEME,
        keep_alive_timeout: keep_alive_timeout
      )
    end

    def disconnect
      return unless defined?(@http)
      return unless @http

      @http.finish
    end

    def post_records_request(records)
      Net::HTTP::Post.new(url).tap do |request|
        request.body = Oj.dump(records)

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

    def validate_keep_alive_timeout(value)
      return value if value >= 0

      raise Fluent::ConfigError, "Invalid keep-alive timeout: #{value.inspect}"
    end
  end
end
