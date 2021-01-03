require 'test_helper'

class JobTest < LambdakiqSpec
  it 'must perform basic job' do
    Lambdakiq::Job.handler(event_basic)
    expect(delete_message).must_be :present?
    expect(change_message_visibility).must_be_nil
    expect(perform_buffer_last_value).must_equal 'BasicJob with: "test"'
    expect(logger).must_include 'Performing TestHelper::Jobs::BasicJob'
    expect(logger).must_include 'Performed TestHelper::Jobs::BasicJob'
  end

  it 'logs cloudwatch embedded metrics' do
    Lambdakiq::Job.handler(event_basic)
    metric = logged_metric('perform.active_job')
    expect(metric).must_be :present?
    expect(metric['AppName']).must_equal 'Dummy'
    expect(metric['JobName']).must_equal 'TestHelper::Jobs::BasicJob'
    expect(metric['Duration']).must_equal 0
    expect(metric['JobId']).must_equal '527cd37e-08f4-4aa8-9834-a46220cdc5a3'
    expect(metric['QueueName']).must_equal 'lambdakiq-JobsQueue-TESTING123.fifo'
    expect(metric['MessageId']).must_equal '9081fe74-bc79-451f-a03a-2fe5c6e2f807'
    expect(metric['JobArg1']).must_equal 'test'
  end

  it 'must change message visibility to next value for failed jobs' do
    event = event_basic attributes: { ApproximateReceiveCount: '7' }, job_class: 'TestHelper::Jobs::ErrorJob'
    expect(->{ Lambdakiq::Job.handler(event) }).must_raise 'HELL'
    expect(change_message_visibility).must_be :present?
    expect(change_message_visibility_params[:visibility_timeout]).must_equal 1416
    expect(perform_buffer_last_value).must_equal 'ErrorJob with: "test"'
    expect(logger).must_include 'Performing TestHelper::Jobs::ErrorJob'
    expect(logger).must_include 'Error performing TestHelper::Jobs::ErrorJob'
  end

  it 'wraps returned errors with no backtrace which avoids excessive/duplicate cloudwatch logging' do
    event = event_basic job_class: 'TestHelper::Jobs::ErrorJob'
    error = expect(->{ Lambdakiq::Job.handler(event) }).must_raise 'HELL'
    expect(error.class.name).must_equal 'Lambdakiq::JobError'
    expect(error.backtrace).must_equal []
    expect(perform_buffer_last_value).must_equal 'ErrorJob with: "test"'
    expect(logger).must_include 'Performing TestHelper::Jobs::ErrorJob'
    expect(logger).must_include 'Error performing TestHelper::Jobs::ErrorJob'
  end

  it 'must delete message for failed jobs at the end of the queue/message max receive count' do
    event = event_basic attributes: { ApproximateReceiveCount: '8' }, job_class: 'TestHelper::Jobs::ErrorJob'
    Lambdakiq::Job.handler(event)
    expect(delete_message).must_be :present?
    expect(perform_buffer_last_value).must_equal 'ErrorJob with: "test"'
    expect(logger).must_include 'Performing TestHelper::Jobs::ErrorJob'
    expect(logger).must_include 'Error performing TestHelper::Jobs::ErrorJob'
  end

  it 'must not perform and allow fifo queue to use message visibility as delay' do
    event = event_basic_delay minutes: 6
    Lambdakiq::Job.handler(event)
    expect(change_message_visibility).must_be :present?
    expect(change_message_visibility_params[:visibility_timeout]).must_equal 6.minutes
    expect(perform_buffer_last_value).must_be_nil
    expect(logger).must_be :blank?
  end

  it 'must not perform and allow fifo queue to use message visibility as delay (using SentTimestamp)' do
    event = event_basic_delay minutes: 10, timestamp: 2.minutes.ago.strftime('%s%3N')
    Lambdakiq::Job.handler(event)
    expect(change_message_visibility).must_be :present?
    expect(change_message_visibility_params[:visibility_timeout]).must_equal 8.minutes
    expect(perform_buffer_last_value).must_be_nil
    expect(logger).must_be :blank?
  end

  it 'must perform and allow fifo queue to use message visibility as delay but not when SentTimestamp is too far in the past' do
    event = event_basic_delay minutes: 2, timestamp: 3.minutes.ago.strftime('%s%3N')
    Lambdakiq::Job.handler(event)
    expect(delete_message).must_be :present?
    expect(change_message_visibility).must_be_nil
    expect(perform_buffer_last_value).must_equal 'BasicJob with: "test"'
    expect(logger).must_include 'Performing TestHelper::Jobs::BasicJob'
    expect(logger).must_include 'Performed TestHelper::Jobs::BasicJob'
  end
end
