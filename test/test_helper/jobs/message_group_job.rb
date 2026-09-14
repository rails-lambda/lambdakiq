module TestHelper
  module Jobs
    class MessageGroupJob < ApplicationJob
      lambdakiq_options message_group_id: ->(job) { "MessageGroupJob-#{job.arguments.first}" }
      def perform(object)
        TestHelper::PerformBuffer.add "MessageGroupJob with: #{object.inspect}"
      end
    end
  end
end
