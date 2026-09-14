module TestHelper
  module Jobs
    class MessageGroupNofifoJob < ApplicationJob
      queue_as ENV['TEST_QUEUE_NAME'].sub('.fifo','')
      lambdakiq_options message_group_id: 'static-group'
      def perform(object)
        TestHelper::PerformBuffer.add "MessageGroupNofifoJob with: #{object.inspect}"
      end
    end
  end
end
