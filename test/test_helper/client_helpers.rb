module TestHelper
  module ClientHelpers

    private

    def client
      Lambdakiq.client.sqs
    end

    def client_reset!
      Lambdakiq.instance_variable_set :@client, nil
    end

    def client_stub_responses
      client.stub_responses(:get_queue_url, {
        queue_url: 'https://sqs.us-stubbed-1.amazonaws.com'
      })
    end

    def api_requests
      client.api_requests
    end

  end
end
