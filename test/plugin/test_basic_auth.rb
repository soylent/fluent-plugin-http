# frozen_string_literal: true

require 'test_helper'
require 'webmock/test_unit'

class TestBaicAuth < Test::Unit::TestCase
  include TestHelpers

  test 'that authorization header is sent when basic auth is enabled' do
    driver = create_driver_with_default_url \
      "username user\n" \
      'password secret'

    request = stub_request(:post, driver.instance.url)

    driver.emit(foo: 'bar')
    driver.run

    assert_requested request.with(
      headers: { 'Authorization' => 'Basic dXNlcjpzZWNyZXQ=' }
    )
  end

  test 'that authorization header is not sent when basic auth is disabled' do
    driver = create_driver_with_default_url
    request = stub_request(:post, driver.instance.url)

    driver.emit(foo: 'bar')
    driver.run

    refute_requested request.with(headers: { 'Authorization' => /.+/ })
  end
end
