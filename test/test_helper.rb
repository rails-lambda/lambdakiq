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
Lambdakiq::Client.default_options.merge! stub_responses: true

class LambdakiqSpec < Minitest::Spec

  include TestHelper::ClientHelpers,
          TestHelper::MessageHelpers,
          TestHelper::EventHelpers

  before do
    client_reset!
    client_stub_responses
  end

end
