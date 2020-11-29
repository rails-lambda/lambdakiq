require 'json'
require 'digest'
require 'active_job'
require 'active_job/queue_adapters'
require 'lambdakiq/version'
require 'lambdakiq/adapter'
require 'lambdakiq/client'
require 'lambdakiq/queue'

# if defined?(Rails)
#   require 'rails/railtie'
#   require 'lambdakiq/railtie'
# end

module Lambdakiq

  def client
    @client ||= Client.new
  end

  extend self

  # autoload :Xyz, 'lambdakiq/xyz'

end
