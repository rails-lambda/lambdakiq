module Lambdakiq
  class Railtie < ::Rails::Railtie
    config.lambdakiq = ActiveSupport::OrderedOptions.new
    # TODO: Should this be per job too?
    config.max_retries = 12
  end
end
