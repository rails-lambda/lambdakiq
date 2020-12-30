module TestHelper
  module Jobs
    class BasicNofifoJob < ApplicationJob
      queue_as 'lambdakiq-JobsQueue-TESTING123'
      def perform(object)
        object
      end
    end
  end
end
