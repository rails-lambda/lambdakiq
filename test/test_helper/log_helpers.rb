module TestHelper
  module LogHelpers
    extend ActiveSupport::Concern

    included do
      let(:logger)  { Rails.logger.instance_variable_get(:@logdev).instance_variable_get(:@dev).string }
    end

    private

    def logged_metric(event)
      metric = logged_metrics.reverse.detect { |l| l.include?(event) }
      JSON.parse(metric) if metric
    end

    def logged_metrics
      logger.each_line.select { |l| l.include? 'CloudWatchMetrics' }
    end

    def logger_reset!
      Rails.logger.instance_variable_get(:@logdev).instance_variable_get(:@dev).truncate 0
    end

  end
end
