require 'test_helper'

class BasicAsyncJobErrorTest < LambdakiqSpec
  it 'logs an error when the message fails to send' do
    client.stub_responses(:send_message, 'ServiceUnavailable')
    job = TestHelper::Jobs::BasicAsyncJob.perform_later('somework')
    wait_for('Waiting for enqueue error log.') { logger.include?('Failed to queue job') }
    expect(logger).must_include "[Lambdakiq] Failed to queue job TestHelper::Jobs::BasicAsyncJob (#{job.job_id})"
  end
end
