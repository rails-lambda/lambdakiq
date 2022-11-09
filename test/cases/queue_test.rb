require 'test_helper'

class QueueTest < LambdakiqSpec
  let(:fifo_queue) { Lambdakiq.client.queues[queue_name] }
  let(:non_fifo_queue) { Lambdakiq.client.queues['non-fifo-queue'] }

  it '#fifo?' do
    expect(fifo_queue.fifo?).must_equal true
    expect(non_fifo_queue.fifo?).must_equal false
  end

  it '#max_receive_count returns the queue redrive policy maxReceiveCount' do
    expect(fifo_queue.max_receive_count).must_equal 8
  end

  it '#max_receive_count returns 1 when the queue does not have a redrive policy' do
    client.stub_responses(:get_queue_attributes, { attributes: {} })
    expect(fifo_queue.max_receive_count).must_equal 1
  end
end
