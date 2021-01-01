require 'test_helper'

class JobTest < LambdakiqSpec
  it 'must change message visibility to next value for failed jobs' do
    event = event_basic attributes: { ApproximateReceiveCount: '7' }, job_class: 'TestHelper::Jobs::ErrorJob'
    expect(->{ Lambdakiq::Job.handler(event) }).must_raise 'HELL'
    expect(change_message_visibility).must_be :present?
    expect(change_message_visibility_params[:visibility_timeout]).must_equal 1416
  end

  it 'wraps returned errors with no backtrace which avoids excessive/duplicate cloudwatch logging' do
    event = event_basic job_class: 'TestHelper::Jobs::ErrorJob'
    error = expect(->{ Lambdakiq::Job.handler(event) }).must_raise 'HELL'
    expect(error.class.name).must_equal 'Lambdakiq::JobError'
    expect(error.backtrace).must_equal []
  end

  it 'must delete message for failed jobs at the end of the queue/message max receive count' do
    event = event_basic attributes: { ApproximateReceiveCount: '8' }, job_class: 'TestHelper::Jobs::ErrorJob'
    Lambdakiq::Job.handler(event)
    expect(delete_message).must_be :present?
  end
end
