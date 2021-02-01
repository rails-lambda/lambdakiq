module TestHelper
  module Jobs
    class ErrorJobOneRetry < ApplicationJob
      lambdakiq_options retry: 1
      def perform(object)
        TestHelper::PerformBuffer.add "ErrorJobOneRetry with: #{object.inspect}"
        raise('HELL')
      end
    end
  end
end
