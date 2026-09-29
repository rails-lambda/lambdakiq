module Lambdakiq
  module Worker
    extend ActiveSupport::Concern

    included do
      class_attribute :lambdakiq_options_hash,
                      instance_predicate: false
      self.lambdakiq_options_hash = Hash.new
    end

    class_methods do

      def lambdakiq_options(options = {})
        self.lambdakiq_options_hash = options.symbolize_keys
      end

    end

    def lambdakiq?
      true
    end

    def lambdakiq_retry
      lambdakiq_options_hash[:retry]
    end

    def lambdakiq_async?
      !!lambdakiq_options_hash[:async]
    end

    def lambdakiq_message_group_id
      group_id = lambdakiq_options_hash[:message_group_id]
      group_id = group_id.call(self) if group_id.respond_to?(:call)
      group_id = group_id.to_s
      group_id.length > 128 ? Digest::SHA256.hexdigest(group_id) : group_id.presence
    end

  end
end
