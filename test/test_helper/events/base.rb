module TestHelper
  module Events
    class Base

      class_attribute :event, instance_writer: false
      self.event = Hash.new

      def self.create(overrides = {})
        overrides[:messageId] ||= SecureRandom.uuid
        job_class = overrides.delete(:job_class)
        event.deep_dup.tap do |e|
          e['Records'].each do |r|
            r.deep_merge!(overrides.deep_stringify_keys)
            r['body'].sub! 'TestHelper::Jobs::BasicJob', job_class if job_class
          end
        end
      end

    end
  end
end
