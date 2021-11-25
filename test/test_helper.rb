ENV['RAILS_ENV'] = 'test'
ENV['TEST_QUEUE_NAME'] ||= 'lambdakiq-JobsQueue-TESTING123.fifo'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup'
Bundler.require :default, :development, :test
require 'rails'
require 'aws-sdk-sqs'
require 'stringio'
require 'timeout'
require 'minitest/autorun'
require 'minitest/focus'
require 'mocha/minitest'
Dir['test/test_helper/*.{rb}'].each { |f| require_relative "../#{f}" }
Lambdakiq::Client.default_options.merge! stub_responses: true
require_relative './dummy_app/init'

class LambdakiqSpec < Minitest::Spec

  include TestHelper::ClientHelpers,
          TestHelper::ApiRequestHelpers,
          TestHelper::EventHelpers,
          TestHelper::QueueHelpers,
          TestHelper::LogHelpers,
          TestHelper::PerformHelpers,
          TestHelper::ResponseHelpers

  before do
    client_reset!
    client_stub_responses
    logger_reset!
    perform_buffer_clear!
  end

  private

  def wait_for(message, timeout: 2)
    Timeout.timeout(timeout) do
      loop do
        value = yield
        value ? break : sleep(0.1)
      end
    end
  rescue Timeout::Error
    flunk(message)
  end

end
