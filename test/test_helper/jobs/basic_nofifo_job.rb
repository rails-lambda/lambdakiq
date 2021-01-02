module TestHelper
  module Jobs
    class BasicNofifoJob < ApplicationJob
      queue_as ENV['TEST_QUEUE_NAME'].sub('.fifo','')
      def perform(object)
        object
      end
    end
  end
end
