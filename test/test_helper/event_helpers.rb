require 'test_helper/events/base'
require 'test_helper/events/basic'
require 'securerandom'

module TestHelper
  module EventHelpers

    MESSAGE_ID = '9081fe74-bc79-451f-a03a-2fe5c6e2f807'.freeze

    private

    def event_basic(overrides = {})
      Events::Basic.create(overrides)
    end

    def event_basic_delay(minutes: 5, timestamp: Time.current.strftime('%s%3N'), overrides: {})
      Events::Basic.create({
        attributes: { SentTimestamp: timestamp },
        messageAttributes: {
          delay_seconds: {
            stringValue: minutes.minutes.to_s,
            stringListValues: [],
            binaryListValues: [],
            dataType: 'String'
          }
        }
      }.merge(overrides))
    end

    def message_id
      MESSAGE_ID
    end

  end
end
