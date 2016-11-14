# frozen_string_literal: true
require 'test_helper'
require 'webmock/test_unit'
require 'fluent/plugin/out_http'

class TestFluentHTTPOutput < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf)
    driver = Fluent::Test::BufferedOutputTestDriver.new(Fluent::HTTPOutput)
    driver.configure(conf)
  end

  sub_test_case 'plugin configuration' do
    test 'that url is required' do
      assert_raise Fluent::ConfigError do
        create_driver ''
      end
    end

    test 'that url scheme must be either http or https' do
      assert_raise Fluent::ConfigError do
        create_driver 'url ws://example.org/'
      end
    end

    test 'that url must be valid' do
      assert_raise Fluent::ConfigError do
        create_driver 'url %'
      end
    end

    test 'that valid url with http scheme is acceptable' do
      driver = create_driver 'url http://example.org/'

      assert_equal URI('http://example.org/'), driver.instance.url
    end

    test 'that valid url with https scheme is acceptable' do
      driver = create_driver 'url https://example.org/'

      assert_equal URI('https://example.org/'), driver.instance.url
    end
  end

  sub_test_case 'request' do
    def setup
      @driver = create_driver('url https://example.org/')
    end

    test 'that event record is sent in the request body' do
      request = stub_request(:post, @driver.instance.url)

      @driver.emit(foo: 'bar')
      @driver.run

      assert_requested request
        .with(body: 'foo=bar')
        .with(headers: { 'User-Agent' => 'FluentPluginHTTP' })
    end

    test 'that unsuccessful response raises an exception' do
      stub_request(:post, @driver.instance.url).to_return(status: 500)
      @driver.emit(foo: 'bar')

      assert_raises(Fluent::HTTPOutput::ResponseError) { @driver.run }
    end
  end
end
