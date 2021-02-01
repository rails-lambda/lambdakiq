require 'test_helper'

class BasicJobTest < LambdakiqSpec
  before do
    TestHelper::Jobs::BasicJob.perform_later('somework')
    expect(sent_message).must_be :present?
  end

  it 'message body' do
    expect(sent_message_body['queue_name']).must_equal queue_name
    expect(sent_message_body['job_class']).must_equal 'TestHelper::Jobs::BasicJob'
    expect(sent_message_body['arguments']).must_equal ['somework']
  end

  it 'message attributes identify this as a Lambdakiq job' do
    lambdakiq = sent_message_attributes['lambdakiq']
    expect(lambdakiq).must_be_instance_of Hash
    expect(lambdakiq[:data_type]).must_equal 'String'
    expect(lambdakiq[:string_value]).must_equal '1'
  end

  it 'message attributes do not include `delay_seconds` since no wait was set' do
    expect(sent_message_attributes.key?('delay_seconds')).must_equal false
  end

  it 'message group and deduplication id for default fifo queue are sent' do
    expect(sent_message_params[:message_deduplication_id]).must_be :present?
    UUID.validate(sent_message_params[:message_deduplication_id])
    expect(sent_message_params[:message_group_id]).must_equal sent_message_params[:message_deduplication_id]
  end
end
