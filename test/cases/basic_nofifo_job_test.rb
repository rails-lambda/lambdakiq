require 'test_helper'

class BasicNofifoJobTest < LambdakiqSpec
  before do
    TestHelper::Jobs::BasicNofifoJob.perform_later('somework')
  end

  it 'message body has no fifo queue nave vs fifo super class ' do
    expect(sent_message_body['queue_name']).must_equal 'lambdakiq-JobsQueue-TESTING123'
  end

  it 'message group and deduplication id not used for non fifo queues' do
    expect(sent_message_params[:message_group_id]).must_be_nil
    expect(sent_message_params[:message_deduplication_id]).must_be_nil
  end
end
