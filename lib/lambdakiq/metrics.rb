module Lambdakiq
  class Metrics

    def initialize
      @logger = ActiveJob::Base.logger
      @namespace = Rails.application.class.name.split('::').first
      @dimensions = Concurrent::Array.new
      @metrics = Concurrent::Array.new
      @properties = Concurrent::Hash.new
    end

    def metrics
      yield(self)
    ensure
      flush
    end

    def flush
      @logger.info(message) unless empty?
    end

    def benchmark
      value = nil
      seconds = Benchmark.realtime { value = yield }
      milliseconds = (seconds * 1000).to_i
      [value, milliseconds]
    end

    def put_dimension(name, value)
      @dimensions << { name => value }
      self
    end

    def put_metric(name, value, unit = nil)
      @metrics << { 'Name' => name }.tap do |m|
        m['Unit'] = unit if unit
      end
      set_property name, value
    end

    def set_property(name, value)
      @properties[name] = value
      self
    end

    def empty?
      [@dimensions, @metrics, @properties].all?(&:empty?)
    end

    def message
      {
        '_aws' => {
          'Timestamp' => timestamp,
          'CloudWatchMetrics' => [
            {
              'Namespace' => @namespace,
              'Dimensions' => [@dimensions.map(&:keys).flatten],
              'Metrics' => @metrics
            }
          ]
        }
      }.tap do |m|
        @dimensions.each { |dim| m.merge!(dim) }
        m.merge!(@properties)
      end
    end

    def timestamp
      Time.now.strftime('%s%3N').to_i
    end

  end
end
