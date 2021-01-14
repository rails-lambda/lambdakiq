module Lambdakiq
  class Message
    LAMBDAKIQ_ATTRIBUTE = { 'lambdakiq' => { string_value: '1', data_type: 'String' } }.freeze

    attr_reader :queue, :job, :options

    def initialize(queue, job, options = {})
      @queue = queue
      @job = job
      @options = options
    end

    def params
      message_params.merge(message_options)
    end

    private

    def message_params
      { message_body: message_body,
        message_attributes: message_attributes }
        .merge(message_params_fifo)
    end

    def message_options
      if queue.fifo?
        options.except(:delay_seconds)
      else
        options
      end
    end

    def message_body
      JSON.dump(job.serialize)
    end

    def message_params_fifo
      if queue.fifo?
        { message_group_id: job.job_id,
          message_deduplication_id: job.job_id }
      else
        {}
      end
    end

    def message_attributes
      LAMBDAKIQ_ATTRIBUTE.merge(delay_seconds_attribute)
    end

    def delay_seconds
      options[:delay_seconds] || 0
    end

    def delay_seconds?
      !delay_seconds.zero?
    end

    def delay_seconds_attribute
      if queue.fifo? && delay_seconds?
        { 'delay_seconds' => { string_value: delay_seconds.to_s, data_type: 'String' } }
      else
        {}
      end
    end

  end
end
