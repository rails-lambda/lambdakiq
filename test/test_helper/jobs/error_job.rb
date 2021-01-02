module TestHelper
  module Jobs
    class ErrorJob < ApplicationJob
      def perform(object)
        TestHelper::PerformBuffer.add "ErrorJob with: #{object.inspect}"
        raise('HELL')
      end
    end
  end
end
