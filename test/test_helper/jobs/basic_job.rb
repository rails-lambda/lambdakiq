module TestHelper
  module Jobs
    class BasicJob < ApplicationJob
      def perform(object)
        Buffer.add "BasicJob with: #{object.inspect}"
      end
    end
  end
end
