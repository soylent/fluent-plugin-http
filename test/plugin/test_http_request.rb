# frozen_string_literal: true
require 'test_helper'
require 'webmock/test_unit'

class TestHTTPRequest < Test::Unit::TestCase
  include TestHelpers

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
