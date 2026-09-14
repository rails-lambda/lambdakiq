module TestHelper
  module Jobs
    class StaticMessageGroupJob < ApplicationJob
      lambdakiq_options message_group_id: 'static-group'
      def perform(object)
        TestHelper::PerformBuffer.add "StaticMessageGroupJob with: #{object.inspect}"
      end
    end
  end
end
