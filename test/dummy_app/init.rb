require 'rails/all'

module Dummy
  class Application < ::Rails::Application
    config.root = File.join __FILE__, '..'
    config.eager_load = true
    logger = ActiveSupport::Logger.new(StringIO.new)
    logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    config.logger = logger
    config.active_job.queue_adapter = :lambdakiq
  end
end

Dummy::Application.initialize!
