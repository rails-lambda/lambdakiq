module Lambdakiq
  class Queue

    attr_reader :queue_name,
                :queue_url

    def initialize(queue_name)
      @queue_name = queue_name
      @queue_url = get_queue_url
    end

    def send_message(job, options = {})
      client.send_message send_message_params(job, options)
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
      { queue_url: queue_url }
        .merge(message_params(job, options))
        .merge(options).tap do |params|
          params.delete(:delay_seconds) if fifo?
        end
    end

    def message_params(job, options)
      { message_body: JSON.dump(job.serialize) }.tap do |params|
        if fifo?
          params[:message_group_id] = 'LambdakiqMessage'
          params[:message_deduplication_id] = job.job_id
        end
        params[:message_attributes] = message_attributes(job, options)
      end
    end

    def message_attributes(_job, options)
      {}.tap do |attrs|
        ds = options[:delay_seconds]
        if ds && fifo?
          attrs['delay_seconds'] = { string_value: ds.to_i.to_s, data_type: 'String' }
        end
      end
    end

  end
end
