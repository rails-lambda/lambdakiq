require 'test_helper'

class RecordTest < LambdakiqSpec
  let(:event)   { event_basic }
  let(:records) { Lambdakiq::Event.records(event) }
  let(:record)  { Lambdakiq::Record.new(records.first) }

  it '#body' do
    expect(record.body).must_be_instance_of String
    expect(JSON.parse(record.body)).must_be_instance_of Hash
  end

  it '#receipt_handle' do
    expect(record.receipt_handle).must_be_instance_of String
    expect(record.receipt_handle).must_match /AQE.*KtD/
  end

  it '#queue_name' do
    expect(record.queue_name).must_equal queue_name
  end

  it '#attributes' do
    expect(record.attributes).must_be_instance_of Hash
  end

  it '#sent_at' do
    sent_at = record.sent_at
    expect(sent_at).must_be_instance_of ActiveSupport::TimeWithZone
    expect(sent_at.year).must_equal 2020
    expect(sent_at.month).must_equal 11
    expect(sent_at.day).must_equal 30
  end

  it '#receive_count' do
    expect(record.receive_count).must_equal 1
  end

end
