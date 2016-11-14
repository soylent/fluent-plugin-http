# frozen_string_literal: true
require 'test/unit'
require 'fluent/test'
require 'fluent/plugin/out_http'

module TestHelpers
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf)
    driver = Fluent::Test::BufferedOutputTestDriver.new(Fluent::HTTPOutput)
    driver.configure(conf)
  end
end
