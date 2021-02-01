require 'test_helper'

class BasicJobNofifoDelayTest < LambdakiqSpec
  before do
    TestHelper::Jobs::BasicNofifoJob.set(wait: 5.minutes).perform_later('somework')
    expect(sent_message).must_be :present?
  end

  it 'uses default `delay_seconds` since non-FIFO queues support this natively' do
    expect(sent_message_params[:delay_seconds]).must_equal 300
  end

  it 'message attributes exclude `delay_seconds` since non-FIFO queues support this natively' do
    delay_seconds = sent_message_attributes['delay_seconds']
    expect(delay_seconds).must_be_nil
  end
end
