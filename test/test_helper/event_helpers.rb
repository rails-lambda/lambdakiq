require 'test_helper/events/base'
require 'test_helper/events/basic'
require 'securerandom'

module TestHelper
  module EventHelpers

    private

    def event_basic(overrides = {})
      Events::Basic.create(overrides)
    end

    def event_basic_delay(minutes: 5, timestamp: Time.current.strftime('%s%3N'))
      Events::Basic.create(
        attributes: { SentTimestamp: timestamp },
        messageAttributes: {
          delay_seconds: {
            stringValue: minutes.minutes.to_s,
            stringListValues: [],
            binaryListValues: [],
            dataType: 'String'
          }
        }
      )
    end

  end
end
