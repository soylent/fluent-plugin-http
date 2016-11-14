# Fluentd `out_http` plugin

The `out_http` buffered output plugin that sends event records via HTTP.

[![Build Status](https://travis-ci.org/soylent/fluent-plugin-http.svg?branch=master)](https://travis-ci.org/soylent/fluent-plugin-http)

## Configuration

    <match foo.bar>
      @type http

      url https://example.org/
      accept_status_code 200,204,303 # Default: 200
    </match>

## Contributing

Bug reports and pull requests are very welcome!
