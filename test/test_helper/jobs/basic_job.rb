module TestHelper
  module Jobs
    class BasicJob < ApplicationJob
      def perform(object)
        TestHelper::PerformBuffer.add "BasicJob with: #{object.inspect}"
      end
    end
  end
end
