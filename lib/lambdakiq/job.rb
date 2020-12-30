module Lambdakiq
  class Job

    attr_reader :record, :error, :sent_timestamp

    class << self

      def handle(event)
        records = Event.records(event)
        jobs = records.map { |record| new(record) }
        jobs.each(&:perform)
        jwerror = jobs.detect{ |j| j.error }
        jwerror ? raise(jwerror.error) : true
      end

    end

    def initialize(record)
      @record = Record.new(record)
      @error = false
    end

    def job_data
      @job_data ||= JSON.parse(record.body)
    end

    def active_job
      @active_job ||= ActiveJob::Base.deserialize(job_data)
    end

    def queue
      Lambdakiq.client.queues[active_job.queue_name]
    end

    def performed?
      @started_at.present? && !error
    end

    def perform
      @started_at = Time.current
      ActiveJob::Base.execute(job_data)
    rescue Exception => e
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
      record.max_receive_count? || record.receive_count >= queue.max_receive_count
    end

  end
end
