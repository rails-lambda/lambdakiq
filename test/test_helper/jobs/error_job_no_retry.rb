module TestHelper
  module Jobs
    class ErrorJobNoRetry < ApplicationJob
      lambdakiq_options retry: 0
      def perform(object)
        TestHelper::PerformBuffer.add "ErrorJobNoRetry with: #{object.inspect}"
        raise('HELL')
      end
    end
  end
end
