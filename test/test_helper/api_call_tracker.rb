module TestHelper
  class ApiCallTracker < Seahorse::Client::Plugin

    @api_calls = []

    class << self

      attr_reader :api_calls

      def called_operations
        api_calls.map { |resp| resp.context.operation_name }
      end

    end

    handle do |context|
      response = @handler.call(context)
      ApiCallTracker.api_calls << response
      response
    end

  end
end
