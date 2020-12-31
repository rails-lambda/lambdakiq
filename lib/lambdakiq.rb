require 'json'
require 'digest'
require 'active_job'
require 'active_job/queue_adapters'
require 'active_support/all'
require 'lambdakiq/version'
require 'lambdakiq/adapter'
require 'lambdakiq/client'
require 'lambdakiq/queue'
require 'lambdakiq/message'
require 'lambdakiq/event'
require 'lambdakiq/job'
require 'lambdakiq/record'
require 'lambdakiq/backoff'
require 'rails/railtie'
require 'lambdakiq/railtie'

module Lambdakiq

  def handler(event)
    Job.handler(event)
  end

  def jobs?(event)
    Event.jobs?(event)
  end

  def client
    @client ||= Client.new
  end

  extend self

end
