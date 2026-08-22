module TestHelper
  module ConfigHelpers
    extend ActiveSupport::Concern

    private

    # Lambdakiq.config is a process wide OrderedOptions shared by every test,
    # so anything a test changes must be put back or it leaks into the others.
    def config_reset!
      Lambdakiq.config.max_retries = 12
      Lambdakiq.config.metrics_namespace = 'Lambdakiq'
      Lambdakiq.config.metrics_enabled = true
      Lambdakiq.config.metrics_logger = Rails.logger
      Lambdakiq.config.metrics_app_name = nil
    end

  end
end
