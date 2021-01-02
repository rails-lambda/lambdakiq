require 'test_helper'

class QueueTest < LambdakiqSpec
  let(:queue) { Lambdakiq.client.queues[queue_name] }

  it '#fifo?' do
    expect(queue.fifo?).must_equal true
  end

  it '#max_receive_count' do
    expect(queue.max_receive_count).must_equal 8
  end
end
