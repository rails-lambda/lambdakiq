module Lambdakiq
  class Railtie < ::Rails::Railtie
    config.lambdakiq = ActiveSupport::OrderedOptions.new
    config.lambdakiq.max_retries = 12
    config.lambdakiq.metrics_namespace = 'Lambdakiq'

    config.after_initialize do
      config.active_job.logger = Rails.logger
      config.lambdakiq.metrics_logger = Rails.logger
    end

    initializer "lambdakiq.metrics" do |app|
      ActiveSupport::Notifications.subscribe(/active_job/) do |*args|
        event = ActiveSupport::Notifications::Event.new *args
        Lambdakiq::Metrics.log(event)
      end
    end
  end
end
