# Fluentd `out_http` plugin

Buffered output plugin that sends event records via HTTP.

[![Build Status](https://travis-ci.org/soylent/fluent-plugin-http.svg?branch=master)](https://travis-ci.org/soylent/fluent-plugin-http)

## Configuration

    <match foo.bar>
      @type http

      # Post event records to this URL
      url https://example.org/

      # Acceptable response status codes (default: 200)
      accept_status_code 200,204,303

      # Keep the connection open for n seconds (default: 60)
      keep_alive_timeout 60

      # Enable token auth
      # authorization_token secret

      # Or enable basic auth
      # username user
      # password secret
    </match>

## Contributing

Bug reports and pull requests are very welcome!
