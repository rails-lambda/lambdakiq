module TestHelper
  module Jobs
    class BasicAsyncJob < ApplicationJob
      lambdakiq_options async: true
      def perform(object)
        TestHelper::PerformBuffer.add "BasicAsyncJob with: #{object.inspect}"
      end
    end
  end
end
