require 'spec_helper'

describe Event do
  it 'requires a valid start' do
    new_event = Event.create({:name => "tech crawl", :start => "mac", :end_time => "2014-08-13 [08:30:00]"})
    expect(new_event).to be_valid
  end
end
