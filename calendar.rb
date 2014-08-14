require 'bundler/setup'
Bundler.require(:default)

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

database_configurations = YAML::load(File.open('./db/config.yml'))
development_configuration = database_configurations['development']
ActiveRecord::Base.establish_connection(development_configuration)

def main_menu
  puts "Calendars"
  puts "1) Create new calendar"
  puts "2) Edit existing calendar"
  puts "3) Exit"
  case gets.chomp.to_i
  when 1
    create_calendar
  when 2
    calendar_login
    calendar_menu
  when 3 then exit
  end
  main_menu
end

def create_calendar
  puts "Enter the name of the new calendar"
  new_calendar = Calendar.new(name: gets.chomp)
  if new_calendar.save
    puts "#{new_calendar.name} created!"
  else
    puts "That wasn't a valid name:"
    new_calendar.errors.full_messages.each { |message| puts message }
  end
end

def calendar_login
  view_calendars
  puts "Enter in the number of the calendar to edit"
  @current_calendar = Calendar.find(gets.chomp.to_i)
end

def view_calendars
  puts "Calendars:"
  Calendar.all.each {|calendar| puts calendar.id.to_s + ") " + calendar.name}
end

def calendar_menu
  puts "1) Create a new event"
  puts "2) Show future events"
  puts "3) Delete an event"
  puts "4) Edit an event"
  puts "5) Today's events"
  puts "10) Exit"
  case gets.chomp.to_i
  when 1 then create_event
  when 2 then list_events_by_date
  when 3 then delete_event
  when 4 then edit_event
  when 5 then today
  when 10 then exit
  end
  calendar_menu
end

def create_event
  puts "Enter the event name"
  name = gets.chomp
  puts "Enter the location of the event"
  location = gets.chomp
  puts "Enter the start date and time (YYYY-MM-DD [HH:MM:SS])"
  start_time = gets.chomp
  puts "Enter the end date and time (YYYY-MM-DD [HH:MM:SS])"
  end_time = gets.chomp
  new_event = @current_calendar.events.new(name: name, location: location, start: start_time, end_time: end_time)
  if new_event.save
    puts "#{new_event.name} created!"
  else
    puts "That wasn't a valid event:"
    new_event.errors.full_messages.each { |message| puts message }
  end
end

def list_events_by_date
  all_events = @current_calendar.events.sort_by{|event| event.start}
  all_events.each do |event|
    if event.start > Time.now
      puts event.id.to_s + ") " + event.start.to_s + " - " + event.end_time.to_s + "\t" + event.name + "\t" + event.location
    end
  end
end

def delete_event
  Event.all.each {|event| puts event.id.to_s + ") " + event.start.to_s + " - " + event.end_time.to_s + "\t" + event.name + "\t" + event.location}
  puts "Enter the number of the event you'd like to delete"
  Event.find(gets.chomp.to_i).destroy
  puts "Event deleted"
end

def edit_event
  Event.all.each {|event| puts event.id.to_s + ") " + event.start.to_s + " - " + event.end_time.to_s + "\t" + event.name + "\t" + event.location}
  puts "Enter the number of the event you'd like to edit"
  event = Event.find(gets.chomp.to_i)
  puts "1) edit name"
  puts "2) edit location"
  puts "3) edit start time"
  puts "4) edit end time"
  case gets.chomp.to_i
    when 1
      puts "Enter the new name:"
      event.update(name: gets.chomp)
    when 2
      puts "Enter the new location"
      event.update(location: gets.chomp)
    when 3
      puts "Enter the new start date and time (YYYY-MM-DD [HH:MM:SS])"
      event.update(start: gets.chomp)
    when 4
      puts "Enter the new end date and time (YYYY-MM-DD [HH:MM:SS])"
      event.update(end_time: gets.chomp)
  end
end

def today
  all_events = @current_calendar.events.sort_by{|event| event.start}
  all_events.each do |event|
    if event.start.to_date == Date.today
      puts event.id.to_s + ") " + event.start.to_s + " - " + event.end_time.to_s + "\t" + event.name + "\t" + event.location
    end
  end
end

main_menu
