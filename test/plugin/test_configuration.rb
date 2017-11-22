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

  test 'that acceptable response status codes can be configured' do
    driver = create_driver_with_default_url 'accept_status_code 201'

    assert_equal ['201'], driver.instance.accept_status_code
  end

  test 'that acceptable response status code is 200 by default' do
    driver = create_driver_with_default_url

    assert_equal ['200'], driver.instance.accept_status_code
  end

  test 'that acceptable response status code can include several values' do
    driver = create_driver_with_default_url 'accept_status_code 200, 201'

    assert_equal %w[200 201], driver.instance.accept_status_code
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

  test 'that authorization token can be configured' do
    driver = create_driver_with_default_url 'authorization_token foo'

    assert_equal 'foo', driver.instance.authorization_token
  end

  test 'that authorization token is nil by default' do
    driver = create_driver_with_default_url

    assert_nil driver.instance.authorization_token
  end

  test 'that authorization token cannot be empty' do
    assert_raise Fluent::ConfigError do
      create_driver_with_default_url 'authorization_token'
    end
  end

  test 'that keep-alive timeout can be an integer' do
    driver = create_driver_with_default_url 'keep_alive_timeout 32'

    assert_equal 32.0, driver.instance.keep_alive_timeout
  end

  test 'that keep-alive timeout can be a float' do
    driver = create_driver_with_default_url 'keep_alive_timeout 32.5'

    assert_equal 32.5, driver.instance.keep_alive_timeout
  end

  test 'that keep-alive timeout is 60 by default' do
    driver = create_driver_with_default_url

    assert_equal 60.0, driver.instance.keep_alive_timeout
  end

  test 'that keep-alive timeout cannot negative' do
    assert_raise Fluent::ConfigError do
      create_driver_with_default_url 'keep_alive_timeout -1'
    end
  end

  test 'that keep-alive timeout is zero if the value is missing' do
    driver = create_driver_with_default_url 'keep_alive_timeout'

    # NOTE: We should throw `Fluent::ConfigError` in this case but
    # Fluentd instead converts the invalid value to zero
    assert_equal 0.0, driver.instance.keep_alive_timeout
  end

  test 'that keep-alive timeout is zero if the value is invalid' do
    driver = create_driver_with_default_url 'keep_alive_timeout oops'

    # NOTE: We should throw `Fluent::ConfigError` in this case but
    # Fluentd instead converts the invalid value to zero
    assert_equal 0.0, driver.instance.keep_alive_timeout
  end
end
