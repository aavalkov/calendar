require 'spec_helper'

describe Event do
  it 'requires a valid start' do
    new_event = Event.create({:name => "tech crawl", :start => "2014-08-13 [06:30:00]", :end_time => "2014-08-13 [08:30:00]"})
    expect(new_event).to be_valid
  end

  describe '.repeat_daily' do
    it 'creates multiple events' do
      new_event = Event.create({:name => "tech crawl", :start => "2014-08-13 [06:30:00]", :end_time => "2014-08-13 [08:30:00]"})
      new_event.repeat_daily(3)
      expect(Event.all.map { |event| event.name }).to eq ["tech crawl", "tech crawl", "tech crawl"]
    end
  end
  describe '.repeat_weekly' do
    it 'creates multiple events' do
      new_event = Event.create({:name => "tech crawl", :start => "2014-08-13 [06:30:00]", :end_time => "2014-08-13 [08:30:00]"})
      new_event.repeat_weekly(3)
      expect(Event.all.map { |event| event.name }).to eq ["tech crawl", "tech crawl", "tech crawl"]
    end
  end
end
