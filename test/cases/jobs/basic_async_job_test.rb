require 'test_helper'

class BasicAsyncJobTest < LambdakiqSpec
  before do
    TestHelper::Jobs::BasicAsyncJob.perform_later('somework')
    expect(sent_message).must_be :blank?
    wait_for('Waiting for sent message API call.') { sent_message }
  end

  it 'message body' do
    expect(sent_message_body['queue_name']).must_equal queue_name
    expect(sent_message_body['job_class']).must_equal 'TestHelper::Jobs::BasicAsyncJob'
    expect(sent_message_body['arguments']).must_equal ['somework']
  end
end
