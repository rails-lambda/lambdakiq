require 'test_helper'

class JobTest < LambdakiqSpec

  it '#active_job - a deserialize representation of what will be executed' do
    e = event_basic messageId: '9081fe74-bc79-451f-a03a-2fe5c6e2f807'
    aj = job(event: e).active_job
    expect(aj).must_be_instance_of TestHelper::Jobs::BasicJob
    expect(aj.job_id).must_equal '527cd37e-08f4-4aa8-9834-a46220cdc5a3'
    expect(aj.queue_name).must_equal queue_name
    expect(aj.enqueued_at).must_equal '2020-11-30T13:07:36Z'
    expect(aj.executions).must_equal 0
    expect(aj.provider_job_id).must_equal '9081fe74-bc79-451f-a03a-2fe5c6e2f807'
  end

  it '#active_job - executions uses ApproximateReceiveCount' do
    event = event_basic attributes: { ApproximateReceiveCount: '3' }
    aj = job(event: event).active_job
    expect(aj.executions).must_equal 2
  end

  it 'must perform basic job' do
    Lambdakiq::Job.handler(event_basic)
    expect(delete_message).must_be :present?
    expect(change_message_visibility).must_be_nil
    expect(perform_buffer_last_value).must_equal 'BasicJob with: "test"'
    expect(logger).must_include 'Performing TestHelper::Jobs::BasicJob'
    expect(logger).must_include 'Performed TestHelper::Jobs::BasicJob'
  end

  it 'logs cloudwatch embedded metrics' do
    Lambdakiq::Job.handler(event_basic(messageId: '9081fe74-bc79-451f-a03a-2fe5c6e2f807'))
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
    # binding.pry ; return
    expect(logged_metric('retry_stopped.active_job')).must_be_nil
    enqueue_retry = logged_metric('enqueue_retry.active_job')
    expect(enqueue_retry).must_be :present?
    expect(enqueue_retry['Executions']).must_equal 7
    expect(enqueue_retry['ExceptionName']).must_equal 'RuntimeError'
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
    # See ClientHelpers for setting queue to max receive count of 8.
    event = event_basic attributes: { ApproximateReceiveCount: '8' }, job_class: 'TestHelper::Jobs::ErrorJob'
    Lambdakiq::Job.handler(event)
    expect(delete_message).must_be :present?
    expect(perform_buffer_last_value).must_equal 'ErrorJob with: "test"'
    expect(logger).must_include 'Performing TestHelper::Jobs::ErrorJob'
    expect(logger).must_include 'Error performing TestHelper::Jobs::ErrorJob'
    expect(logged_metric('enqueue_retry.active_job')).must_be_nil
    retry_stopped = logged_metric('retry_stopped.active_job')
    expect(retry_stopped).must_be :present?
    expect(retry_stopped['Executions']).must_equal 8
    expect(retry_stopped['ExceptionName']).must_equal 'RuntimeError'
  end

  it 'must not perform and allow fifo queue to use message visibility as delay' do
    event = event_basic_delay minutes: 6
    error = expect(->{ Lambdakiq::Job.handler(event) }).must_raise 'HELL'
    expect(delete_message).must_be :blank?
    expect(change_message_visibility).must_be :present?
    expect(change_message_visibility_params[:visibility_timeout]).must_be_close_to 6.minutes, 1
    expect(perform_buffer_last_value).must_be_nil
    expect(logger).must_be :blank?
  end

  it 'must not perform and allow fifo queue to use message visibility as delay (using SentTimestamp)' do
    event = event_basic_delay minutes: 10, timestamp: 2.minutes.ago.strftime('%s%3N')
    error = expect(->{ Lambdakiq::Job.handler(event) }).must_raise 'HELL'
    expect(delete_message).must_be :blank?
    expect(change_message_visibility).must_be :present?
    expect(change_message_visibility_params[:visibility_timeout]).must_be_close_to 8.minutes, 1
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

  it 'must use `lambdakiq_options` retry options set to 0 and not retry job' do
    event = event_basic job_class: 'TestHelper::Jobs::ErrorJobNoRetry'
    Lambdakiq::Job.handler(event)
    expect(delete_message).must_be :present?
    expect(perform_buffer_last_value).must_equal 'ErrorJobNoRetry with: "test"'
    expect(logger).must_include 'Performing TestHelper::Jobs::ErrorJobNoRetry'
    expect(logger).must_include 'Error performing TestHelper::Jobs::ErrorJobNoRetry'
  end

  it 'must use `lambdakiq_options` retry options set to 1 and retry job' do
    event = event_basic job_class: 'TestHelper::Jobs::ErrorJobOneRetry'
    error = expect(->{ Lambdakiq::Job.handler(event) }).must_raise 'HELL'
    expect(delete_message).must_be :blank?
    expect(perform_buffer_last_value).must_equal 'ErrorJobOneRetry with: "test"'
    expect(change_message_visibility).must_be :present?
    expect(change_message_visibility_params[:visibility_timeout]).must_equal 30.seconds
    expect(logger).must_include 'Performing TestHelper::Jobs::ErrorJobOneRetry'
    expect(logger).must_include 'Error performing TestHelper::Jobs::ErrorJobOneRetry'
  end

  private

  def job(event: event_basic)
    record = Lambdakiq::Event.records(event).first
    Lambdakiq::Job.new(record)
  end

end
