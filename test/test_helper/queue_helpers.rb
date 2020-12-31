module TestHelper
  module QueueHelpers

    private

    def queue_name
      ENV['TEST_QUEUE_NAME']
    end

    def stub_get_queue_attributes(maxReceiveCount: 13)
      redrive_policy = JSON.dump({maxReceiveCount: maxReceiveCount.to_s})
      client.stub_responses(:get_queue_attributes, {
        attributes: { 'RedrivePolicy' => redrive_policy }
      })
    end

  end
end
