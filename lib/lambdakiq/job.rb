module Lambdakiq
  class Job

    attr_reader :record, :error

    class << self

      def handler(event)
        records = Event.records(event)
        jobs = records.map { |record| new(record) }
        jobs.each(&:perform)
        jwerror = jobs.detect{ |j| j.error }
        return unless jwerror
        raise JobError.new(jwerror.error)
      end

    end

    def initialize(record)
      @record = Record.new(record)
      @error = false
    end

    def job_data
      @job_data ||= JSON.parse(record.body).tap do |data|
        data['provider_job_id'] = record.message_id
        data['executions'] = record.receive_count - 1
      end
    end

    def active_job
      @active_job ||= ActiveJob::Base.deserialize(job_data)
    end

    def queue
      Lambdakiq.client.queues[active_job.queue_name]
    end

    def executions
      active_job.executions
    end

    def perform
      fifo_delay? ? fifo_delay : execute
    end

    def execute
      ActiveJob::Base.execute(job_data)
      delete_message
    rescue Exception => e
      increment_executions
      perform_error(e)
    end

    private

    def client_params
      { queue_url: queue.queue_url, receipt_handle: record.receipt_handle }
    end

    def perform_error(e)
      if change_message_visibility
        @error = e
      else
        delete_message
      end
    end

    def delete_message
      client.delete_message(client_params)
    rescue Exception => e
      true
    end

    def change_message_visibility
      return false if max_receive_count?
      params = client_params.merge visibility_timeout: record.next_visibility_timeout
      client.change_message_visibility(params)
      true
    end

    def client
      Lambdakiq.client.sqs
    end

    def max_receive_count?
      executions > retry_limit
    end

    def retry_limit
      config_retry = [Lambdakiq.config.max_retries, 12].min
      [ (active_job.lambdakiq_retry || config_retry),
        (queue.max_receive_count - 1) ].min
    end

    def fifo_delay?
      queue.fifo? && record.fifo_delay_seconds?
    end

    def fifo_delay
      params = client_params.merge visibility_timeout: record.fifo_delay_visibility_timeout
      client.change_message_visibility(params)
    end

    def increment_executions
      active_job.executions = active_job.executions + 1
    end

  end
end
