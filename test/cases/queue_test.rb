require 'test_helper'

class QueueTest < LambdakiqSpec
  it '#max_receive_count' do
    stub_get_queue_attributes maxReceiveCount: 8
    queue = Lambdakiq.client.queues[queue_name]
    expect(queue.max_receive_count).must_equal 8
  end
end
