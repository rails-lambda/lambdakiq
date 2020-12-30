module Lambdakiq
  class Railtie < ::Rails::Railtie
    config.lambdakiq = ActiveSupport::OrderedOptions.new
    config.lambdakiq.max_retries = 12
  end
end
