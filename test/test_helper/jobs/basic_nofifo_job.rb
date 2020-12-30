module TestHelper
  module Jobs
    class BasicNofifoJob < ApplicationJob
      queue_as 'lambdakiq-JobsQueue-TESTING123'
      def perform(object)
        Buffer.add "BasicNofifoJob with: #{object.inspect}"
      end
    end
  end
end
