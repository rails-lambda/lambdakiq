module TestHelper
  module LogHelpers
    extend ActiveSupport::Concern

    included do
      let(:logger) { Dummy::Application::LOG_IO.string }
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
      Dummy::Application::LOG_IO.truncate(0)
      Dummy::Application::LOG_IO.rewind
    end

  end
end
