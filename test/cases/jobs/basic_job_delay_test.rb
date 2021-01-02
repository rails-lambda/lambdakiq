require 'test_helper'

class BasicJobDelayTest < LambdakiqSpec
  before do
    TestHelper::Jobs::BasicJob.set(wait: 5.minutes).perform_later('somework')
    expect(sent_message).must_be :present?
  end

  it 'message attributes include `delay_seconds` since no wait was set' do
    delay_seconds = sent_message_attributes['delay_seconds']
    expect(delay_seconds).must_be :present?
    expect(delay_seconds[:data_type]).must_equal 'String'
    expect(delay_seconds[:string_value]).must_equal '300'
  end
end
