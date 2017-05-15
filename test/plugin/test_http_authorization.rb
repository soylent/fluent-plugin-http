# frozen_string_literal: true

require 'test_helper'
require 'webmock/test_unit'

class TestHTTPAuthorization < Test::Unit::TestCase
  include TestHelpers

  test 'that authorization header is sent when the token is specified' do
    driver = create_driver_with_default_url('authorization_token secret')
    request = stub_request(:post, driver.instance.url)

    driver.emit(foo: 'bar')
    driver.run

    assert_requested request.with(
      headers: { 'Authorization' => 'Token token=secret' }
    )
  end

  test 'that authorization header is not sent when the token is nil' do
    driver = create_driver_with_default_url
    request = stub_request(:post, driver.instance.url)

    driver.emit(foo: 'bar')
    driver.run

    refute_requested request.with(headers: { 'Authorization' => /.+/ })
  end
end
