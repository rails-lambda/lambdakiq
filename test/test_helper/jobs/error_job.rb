module TestHelper
  module Jobs
    class ErrorJob < ApplicationJob
      def perform(object)
        raise('HELL')
      end
    end
  end
end
