ENV['RAILS_ENV'] = 'test'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup'
Bundler.require :default, :development, :test
require 'aws-sdk-sqs'
require 'minitest/autorun'
require 'minitest/focus'
require 'mocha/minitest'
Dir['test/test_helper/*.{rb}'].each { |f| require_relative "../#{f}" }

ActiveJob::Base.queue_adapter = :lambdakiq
ActiveJob::Base.logger = Logger.new(IO::NULL)
Aws::SQS::Client.add_plugin(TestHelper::ApiCallTracker)
Lambdakiq::Client.default_options.merge! stub_responses: true

class LambdakiqSpec < Minitest::Spec

  include TestHelper::ClientHelpers,
          TestHelper::MessageHelpers

  before do
    client_reset!
    client_stub_responses
    clear_api_tracker!
    clear_jobs_buffer!
  end

  private

  def event_basic(overrides = {})
    TestHelper::Events::Basic.create(overrides)
  end

  def clear_api_tracker!
    TestHelper::ApiCallTracker.api_calls.clear
  end

  def clear_jobs_buffer!
    TestHelper::Jobs::Buffer.clear
  end

  def buffer_last_value
    TestHelper::Jobs::Buffer.last_value
  end

end
