# Fluentd `out_http` plugin

The `out_http` buffered output plugin that sends event records via HTTP.

[![Build Status](https://travis-ci.org/soylent/fluent-plugin-http.svg?branch=master)](https://travis-ci.org/soylent/fluent-plugin-http)

## Configuration

    <match foo.bar>
      @type http

      url https://example.org/
    </match>

## Contributing

Bug reports and pull requests are very welcome!
