module TestHelper
  module Jobs
    class ApplicationJob < ActiveJob::Base
      queue_as ENV['TEST_QUEUE_NAME']
      include Lambdakiq::Worker
    end
  end
end
