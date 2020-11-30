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

    def attributes
      data['attributes']
    end

    def queue_name
      @queue_name ||= data['eventSourceARN'].split(':').last
    end

    def sent_at
       @sent_at ||= begin
        ts = attributes['SentTimestamp'].to_i
        Time.at(ts/1000)
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
