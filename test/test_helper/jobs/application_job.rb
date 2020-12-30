module TestHelper
  module Jobs
    class ApplicationJob < ActiveJob::Base
      queue_as 'lambdakiq-JobsQueue-TESTING123.fifo'
    end
  end
end
