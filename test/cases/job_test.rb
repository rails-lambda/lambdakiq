require 'test_helper'

class JobTest < LambdakiqSpec
  it 'must change message visibility to next value for failed jobs' do
    stub_get_queue_attributes maxReceiveCount: 8
    event = event_basic attributes: { ApproximateReceiveCount: '7' }, job_class: 'TestHelper::Jobs::ErrorJob'
    expect(->{ Lambdakiq::Job.handler(event) }).must_raise 'HELL'
    expect(change_message_visibility).must_be :present?
    expect(change_message_visibility_params[:visibility_timeout]).must_equal 1416
  end

  it 'must delete message for failed jobs at the end of the queue/message max receive count' do
    stub_get_queue_attributes maxReceiveCount: 8
    event = event_basic attributes: { ApproximateReceiveCount: '8' }, job_class: 'TestHelper::Jobs::ErrorJob'
    Lambdakiq::Job.handler(event)
    expect(delete_message).must_be :present?
  end
end
