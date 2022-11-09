module Lambdakiq
  class Queue

    attr_reader :queue_name,
                :queue_url

    def initialize(queue_name)
      @queue_name = queue_name
      @queue_url = get_queue_url
      attributes
    end

    def send_message(job, options = {})
      client.send_message send_message_params(job, options)
    end

    def attributes
      @attributes ||= client.get_queue_attributes({
        queue_url: queue_url,
        attribute_names: ['All']
      }).attributes
    end

    def redrive_policy
      @redrive_policy ||= attributes['RedrivePolicy'] ? JSON.parse(attributes['RedrivePolicy']) : nil
    end

    def max_receive_count
      redrive_policy&.dig('maxReceiveCount')&.to_i || 1
    end

    def fifo?
      queue_name.ends_with?('.fifo')
    end

    private

    def client
      Lambdakiq.client.sqs
    end

    def get_queue_url
      client.get_queue_url(queue_name: queue_name).queue_url
    end

    def send_message_params(job, options)
      { queue_url: queue_url }.merge(message_params(job, options))
    end

    def message_params(job, options)
      Message.new(self, job, options).params
    end

  end
end
