require 'test_helper'

class MessageGroupJobTest < LambdakiqSpec
  it 'message group id is built from the job when given a proc' do
    TestHelper::Jobs::MessageGroupJob.perform_later('somework')
    expect(sent_message_params[:message_group_id]).must_equal 'MessageGroupJob-somework'
  end

  it 'message group id is used as is when given a string' do
    TestHelper::Jobs::StaticMessageGroupJob.perform_later('somework')
    expect(sent_message_params[:message_group_id]).must_equal 'static-group'
  end

  it 'message deduplication id is still the unique job id' do
    job = TestHelper::Jobs::MessageGroupJob.perform_later('somework')
    expect(sent_message_params[:message_deduplication_id]).must_equal job.job_id
  end

  it 'message group id not used for non fifo queues' do
    TestHelper::Jobs::MessageGroupNofifoJob.perform_later('somework')
    expect(sent_message_params[:message_group_id]).must_be_nil
  end
end
