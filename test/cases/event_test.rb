require 'test_helper'

class EventTest < LambdakiqSpec
  it '.records' do
    event = event_basic
    records = Lambdakiq::Event.records(event)
    expect(records).must_be_instance_of(Array)
    expect(records.length).must_equal(1)
  end

  it '.jobs?' do
    event = event_basic
    jobs = Lambdakiq::Event.jobs?(event)
    expect(jobs).must_equal(true)
  end
end
