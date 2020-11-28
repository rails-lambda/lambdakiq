module Lambdakiq
  class Railtie < ::Rails::Railtie
    config.lambdakiq = ActiveSupport::OrderedOptions.new
  end
end
