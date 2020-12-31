module TestHelper
  module Jobs
    class ApplicationJob < ActiveJob::Base
      queue_as ENV['TEST_QUEUE_NAME']
    end
  end
end
