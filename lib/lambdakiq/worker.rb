module Lambdakiq
  module Worker
    extend ActiveSupport::Concern

    included do
      class_attribute :lambdakiq_options_hash,
                      instance_predicate: false,
                      default: Hash.new
    end

    class_methods do

      def lambdakiq_options(options = {})
        self.lambdakiq_options_hash = options.symbolize_keys
      end

    end

    def lambdakiq_retry
      lambdakiq_options_hash[:retry]
    end

    def lambdakiq_async?
      !!lambdakiq_options_hash[:async]
    end

  end
end
