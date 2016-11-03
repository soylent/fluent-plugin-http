# frozen_string_literal: true
module Fluent
  class HTTPOutput
    # Unsuccessful response error
    ResponseError = Class.new(StandardError) do
      def self.error(request, response)
        new "Failed to POST event record to #{request.uri} because of " \
            "unsuccessful response code: #{response.code.inspect} " \
            "#{response.body.inspect}"
      end
    end
  end
end
