module Lambdakiq
  class Queue
    attr_reader :queue_name,
                :queue_url

    def initialize(queue_name)
      @queue_name = queue_name
      @queue_url = get_queue_url
    end

    def send_message(job, options = {})
      client.send_message params(job, options)
    end

    private

    def client
      Lambdakiq.client.sqs
    end

    def params(job, options)
      message_params(job)
        .merge(queue_url: queue_url)
        .merge(options)
    end

    def message_params(job)
      { message_body: JSON.dump(job.serialize),
        message_group_id: 'LambdakiqMessage',
        message_deduplication_id: job.job_id }
    end

    def get_queue_url
      client.get_queue_url(queue_name: queue_name).queue_url
    end

  end
end
