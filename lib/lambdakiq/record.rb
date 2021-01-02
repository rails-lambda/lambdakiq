module Lambdakiq
  class Record

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def body
      data['body']
    end

    def receipt_handle
      data['receiptHandle']
    end

    def queue_name
      @queue_name ||= data['eventSourceARN'].split(':').last
    end

    def attributes
      data['attributes']
    end

    def fifo_delay_visibility_timeout
      fifo_delay_seconds - (Time.current - sent_at).to_i
    end

    def fifo_delay_seconds
      data.dig('messageAttributes', 'delay_seconds', 'stringValue').try(:to_i)
    end

    def fifo_delay_seconds?
      fifo_delay_seconds && (sent_at + fifo_delay_seconds).future?
    end

    def sent_at
       @sent_at ||= begin
        ts = attributes['SentTimestamp'].to_i / 1000
        Time.zone ? Time.zone.at(ts) : Time.at(ts)
      end
    end

    def receive_count
      @receive_count ||= attributes['ApproximateReceiveCount'].to_i
    end

    def max_receive_count?
      receive_count >= 12
    end

    def next_visibility_timeout
      @next_visibility_timeout ||= Backoff.backoff(receive_count)
    end

  end
end
