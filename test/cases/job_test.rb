require 'test_helper'

class JobTest < LambdakiqSpec
  it 'must perform basic job' do
    Lambdakiq::Job.handler(event_basic)
    expect(delete_message).must_be :present?
    expect(change_message_visibility).must_be_nil
    expect(perform_buffer_last_value).must_equal 'BasicJob with: "test"'
    expect(active_job_log).must_include 'Performing TestHelper::Jobs::BasicJob'
    expect(active_job_log).must_include 'Performed TestHelper::Jobs::BasicJob'
  end

  it 'must change message visibility to next value for failed jobs' do
    event = event_basic attributes: { ApproximateReceiveCount: '7' }, job_class: 'TestHelper::Jobs::ErrorJob'
    expect(->{ Lambdakiq::Job.handler(event) }).must_raise 'HELL'
    expect(change_message_visibility).must_be :present?
    expect(change_message_visibility_params[:visibility_timeout]).must_equal 1416
    expect(perform_buffer_last_value).must_equal 'ErrorJob with: "test"'
    expect(active_job_log).must_include 'Performing TestHelper::Jobs::ErrorJob'
    expect(active_job_log).must_include 'Error performing TestHelper::Jobs::ErrorJob'
  end

  it 'wraps returned errors with no backtrace which avoids excessive/duplicate cloudwatch logging' do
    event = event_basic job_class: 'TestHelper::Jobs::ErrorJob'
    error = expect(->{ Lambdakiq::Job.handler(event) }).must_raise 'HELL'
    expect(error.class.name).must_equal 'Lambdakiq::JobError'
    expect(error.backtrace).must_equal []
    expect(perform_buffer_last_value).must_equal 'ErrorJob with: "test"'
    expect(active_job_log).must_include 'Performing TestHelper::Jobs::ErrorJob'
    expect(active_job_log).must_include 'Error performing TestHelper::Jobs::ErrorJob'
  end

  it 'must delete message for failed jobs at the end of the queue/message max receive count' do
    event = event_basic attributes: { ApproximateReceiveCount: '8' }, job_class: 'TestHelper::Jobs::ErrorJob'
    Lambdakiq::Job.handler(event)
    expect(delete_message).must_be :present?
    expect(perform_buffer_last_value).must_equal 'ErrorJob with: "test"'
    expect(active_job_log).must_include 'Performing TestHelper::Jobs::ErrorJob'
    expect(active_job_log).must_include 'Error performing TestHelper::Jobs::ErrorJob'
  end

  it 'must not perform and allow fifo queue to use message visibility as delay' do
    event = event_basic_delay minutes: 6
    Lambdakiq::Job.handler(event)
    expect(change_message_visibility).must_be :present?
    expect(change_message_visibility_params[:visibility_timeout]).must_equal 6.minutes
    expect(perform_buffer_last_value).must_be_nil
    expect(active_job_log).must_be :blank?
  end

  it 'must not perform and allow fifo queue to use message visibility as delay (using SentTimestamp)' do
    event = event_basic_delay minutes: 10, timestamp: 2.minutes.ago.strftime('%s%3N')
    Lambdakiq::Job.handler(event)
    expect(change_message_visibility).must_be :present?
    expect(change_message_visibility_params[:visibility_timeout]).must_equal 8.minutes
    expect(perform_buffer_last_value).must_be_nil
    expect(active_job_log).must_be :blank?
  end

  it 'must perform and allow fifo queue to use message visibility as delay but not when SentTimestamp is too far in the past' do
    event = event_basic_delay minutes: 2, timestamp: 3.minutes.ago.strftime('%s%3N')
    Lambdakiq::Job.handler(event)
    expect(delete_message).must_be :present?
    expect(change_message_visibility).must_be_nil
    expect(perform_buffer_last_value).must_equal 'BasicJob with: "test"'
    expect(active_job_log).must_include 'Performing TestHelper::Jobs::BasicJob'
    expect(active_job_log).must_include 'Performed TestHelper::Jobs::BasicJob'
  end
end
