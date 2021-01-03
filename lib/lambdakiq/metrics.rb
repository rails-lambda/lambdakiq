module Lambdakiq
  class Metrics
    attr_reader :event

    class << self
      def log(event)
        new(event).log
      end
    end

    def initialize(event)
      @event = event
      @metrics = []
      @properties = {}
      instrument!
    end

    def log
      logger.info JSON.dump(message)
    end

    private

    def job
      event.payload[:job]
    end

    def job_name
      job.class.name
    end

    def logger
      Lambdakiq.config.metrics_logger
    end

    def namespace
      Lambdakiq.config.metrics_namespace
    end

    def exception
      event.payload[:exception].try(:first)
    end

    def dimensions
      [
        { AppName: rails_app_name },
        { JobEvent: event.name },
        { JobName: job_name }
      ]
    end

    def instrument!
      put_metric 'Duration', event.duration.to_i, 'Milliseconds'
      put_metric job_name, 1, 'Count'
      put_metric 'Exceptions', 1, 'Count' if exception
      set_property 'JobId', job.job_id
      set_property 'JobName', job_name
      set_property 'QueueName', job.queue_name
      set_property 'MessageId', job.provider_job_id if job.provider_job_id
      set_property 'Exception', exception if exception
      set_property 'EnqueuedAt', job.enqueued_at if job.enqueued_at
      set_property 'Executions', job.executions if job.executions
      job.arguments.each_with_index do |argument, index|
        set_property "JobArg#{index+1}", argument
      end
    end

    def put_metric(name, value, unit = nil)
      @metrics << { 'Name': name }.tap do |m|
        m['Unit'] = unit if unit
      end
      set_property name, value
    end

    def set_property(name, value)
      @properties[name] = value
      self
    end

    def message
      {
        '_aws': {
          'Timestamp': timestamp,
          'CloudWatchMetrics': [
            {
              'Namespace': namespace,
              'Dimensions': [dimensions.map(&:keys).flatten],
              'Metrics': @metrics
            }
          ]
        }
      }.tap do |m|
        dimensions.each { |d| m.merge!(d) }
        m.merge!(@properties)
      end
    end

    def timestamp
      Time.current.strftime('%s%3N').to_i
    end

    def rails_app_name
      Rails.application.class.name.split('::').first
    end

  end
end

