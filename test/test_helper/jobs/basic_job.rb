module TestHelper
  module Jobs
    class BasicJob < ApplicationJob
      def perform(object)
        object
      end
    end
  end
end
