# frozen_string_literal: true
require 'test_helper'

class TestConfiguration < Test::Unit::TestCase
  include TestHelpers

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

  def create_driver_with_default_url(conf)
    create_driver "url https://example.org/\n#{conf}"
  end

  test 'that acceptable response status codes can be configured' do
    driver = create_driver_with_default_url 'accept_status_code 201'

    assert_equal ['201'], driver.instance.accept_status_code
  end

  test 'that acceptable response status code is 200 by default' do
    driver = create_driver_with_default_url ''

    assert_equal ['200'], driver.instance.accept_status_code
  end

  test 'that acceptable response status code can include several values' do
    driver = create_driver_with_default_url 'accept_status_code 200, 201'

    assert_equal %w(200 201), driver.instance.accept_status_code
  end

  test 'that acceptable response status code cannot be empty' do
    assert_raise Fluent::ConfigError do
      create_driver_with_default_url 'accept_status_code'
    end
  end

  test 'that acceptable response status code cannot be less than 100' do
    assert_raise Fluent::ConfigError do
      create_driver_with_default_url 'accept_status_code 99'
    end
  end

  test 'that acceptable response status code cannot be more than 599' do
    assert_raise Fluent::ConfigError do
      create_driver_with_default_url 'accept_status_code 600'
    end
  end
end
