require 'test_helper'

class QueueTest < LambdakiqSpec
  it '#max_receive_count' do
    queue = Lambdakiq.client.queues[queue_name]
    expect(queue.max_receive_count).must_equal 8
  end
end
