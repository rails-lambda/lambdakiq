module TestHelper
  module QueueHelpers

    private

    def queue_name
      ENV['TEST_QUEUE_NAME']
    end

  end
end
