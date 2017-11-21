# frozen_string_literal: true

require 'test_helper'
require 'webmock/test_unit'

class TestHTTPRequest < Test::Unit::TestCase
  include TestHelpers

  def setup
    @driver = create_driver_with_default_url('accept_status_code 200, 303')
  end

  test 'that event record is sent' do
    request = stub_request(:post, @driver.instance.url)

    @driver.emit(foo: 'bar')
    @driver.run

    assert_requested request.with(
      body: '[{"foo":"bar"}]',
      headers: { 'User-Agent' => 'FluentPluginHTTP' }
    )
  end

  test 'that unacceptable response status code raises an exception' do
    stub_request(:post, @driver.instance.url).to_return(status: 500)

    @driver.emit(foo: 'bar')

    assert_raises(Fluent::HTTPOutput::ResponseError) { @driver.run }
  end

  test 'that acceptable response status code does not raise an exception' do
    stub_request(:post, @driver.instance.url).to_return(status: 303)

    @driver.emit(foo: 'bar')

    assert_nothing_raised { @driver.run }
  end

  test 'that the strings are considered UTF-8 encoded' do
    request = stub_request(:post, @driver.instance.url)

    string = "\xE8\x81\x94\xE6\x83\xB3".dup

    @driver.emit(foo: string.force_encoding('ASCII-8BIT'))
    @driver.run

    assert_requested request.with(body: '[{"foo":"联想"}]')
  end

  test 'that empty chunks are not sent' do
    request = stub_request(:post, @driver.instance.url)

    @driver.run

    assert_not_requested request
  end
end
