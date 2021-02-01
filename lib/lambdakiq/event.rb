module Lambdakiq
  module Event

    def jobs?(event)
      records(event).any? { |r| job?(r) }
    end

    def job?(record)
      record.dig('messageAttributes', 'lambdakiq', 'stringValue') == '1'
    end

    def records(event)
      event['Records'] || []
    end

    extend self

  end
end
