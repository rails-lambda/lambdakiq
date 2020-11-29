module Lambdakiq
  class Client

    attr_reader :queues

    def initialize
      @queues = Hash.new do |h, name|
        h[name] = Queue.new(name)
      end
    end

    def sqs
      @sqs ||= begin
        require 'aws-sdk-sqs'
        Aws::SQS::Client.new(options)
      end
    end

    private

    def options
      default_options.tap do |opts|
        opts[:region] = region if region
      end
    end

    def region
      ENV['AWS_REGION']
    end

    def default_options
      {}
    end

  end
end
