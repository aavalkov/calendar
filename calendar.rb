require 'bundler/setup'
Bundler.require(:default)
require 'textacular'

ActiveRecord::Base.extend(Textacular)

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

database_configurations = YAML::load(File.open('./db/config.yml'))
development_configuration = database_configurations['development']
ActiveRecord::Base.establish_connection(development_configuration)

def main_menu
  puts "Calendars"
  puts "1) Create new calendar"
  puts "2) Edit existing calendar"
  puts "4) Create new to-do item"
  puts "3) Exit"
  case gets.chomp.to_i
  when 1
    create_calendar
  when 2
    calendar_login
    calendar_menu
  when 3 then exit
  when 4 then todo_menu
  end
  main_menu
end

def todo_menu
  puts "1) Create new to-do item"
  puts "2) View to-do list"
  puts "3) Add a note to a to-do item"
  puts "4) Main Menu"
  case gets.chomp.to_i
  when 1 then create_todo
  when 2 then view_todos
  when 3 then add_note_todo
  when 4 then main_menu
  end
  todo_menu
end

def create_todo
  puts "Enter the description"
  Todo.create(description: gets.chomp)
  puts "Success!"
end

def view_todos
  puts "To-Do Items"
  Todo.all.each do |todo|
    puts todo.id.to_s + ") " + todo.description
    todo.notes.each {|note| puts note.description}
  end
end

def add_note_todo
  view_todos
  puts "Enter the number of the to-do item to add the note"
  current_todo = Todo.find(gets.chomp.to_i)
  puts "Enter the note to be added"
  current_todo.notes.create(description: gets.chomp)
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
  puts "6) This week's events"
  puts "7) This month's events"
  puts "8) Add note to event"
  puts "9) Display notes"
  puts "10) Search"
  puts "12) Exit"
  case gets.chomp.to_i
  when 1 then create_event
  when 2 then list_events_by_date
  when 3 then delete_event
  when 4 then edit_event
  when 5
    @selected_day = Date.today
    today
  when 6
    @selected_week = Date.today
    week
  when 7
    @selected_month = Date.today
    month
  when 8 then add_note_event
  when 9 then view_event_details
  when 10 then search
  when 12 then exit
  end
  calendar_menu
end

def search
  puts "Enter the thing you'd like to search for"
  Event.basic_search(gets.chomp).each do |event|
    puts event.id.to_s + ") " + event.start.to_s + " - " + event.end_time.to_s + "\t" + event.name + "\t" + event.location
    event.notes.each{|note| puts note.description}
  end
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
  display_events(@selected_day)
  puts "Enter 1 to go back a day, 2 to go forward, 3 to go back to the menu"
  case gets.chomp.to_i
  when 1
    @selected_day -= 1
    today
  when 2
    @selected_day += 1
    today
  when 3
    calendar_menu
  end
end

def display_events(selected_day)
  all_events = @current_calendar.events.sort_by{|event| event.start}
  all_events.each do |event|
    if event.start.to_date == selected_day
      puts event.id.to_s + ") " + event.start.to_s + " - " + event.end_time.to_s + "\t" + event.name + "\t" + event.location
    end
  end
end

def week
  sunday = @selected_week - @selected_week.wday
  saturday = sunday + 6
  all_events = @current_calendar.events.sort_by{|event| event.start}
  all_events.each do |event|
    if event.start.to_date >= sunday && event.start.to_date <= saturday
      puts event.id.to_s + ") " + event.start.to_s + " - " + event.end_time.to_s + "\t" + event.name + "\t" + event.location
    end
  end
  puts "Press 1 to go back a week, 2 to go forward a week, or 3 to return to the menu"
  case gets.chomp.to_i
    when 1
      @selected_week = @selected_week - 7
      week
    when 2
      @selected_week = @selected_week +7
      week
    when 3
      calendar_menu
  end
end

def month
  all_events = @current_calendar.events.sort_by{|event| event.start}
  all_events.each do |event|
    if event.start.to_date.year == @selected_month.year && event.start.to_date.month == @selected_month.month
      puts event.id.to_s + ") " + event.start.to_s + " - " + event.end_time.to_s + "\t" + event.name + "\t" + event.location
    end
  end
  puts " Press 1 to go back a month, 2 to go forward a month, or 3 to return to the menu"
  case gets.chomp.to_i
    when 1
      @selected_month = @selected_month.prev_month
      month
    when 2
      @selected_month = @selected_month.next_month
      month
    when 3
      calendar_menu
  end
end

def add_note_event
  Event.all.each {|event| puts event.id.to_s + ") " + event.start.to_s + " - " + event.end_time.to_s + "\t" + event.name + "\t" + event.location}
  puts "Enter the number of the event you'd like to edit"
  event = Event.find(gets.chomp.to_i)
  puts "Enter the description"
  event.notes.create(description: gets.chomp)
  puts "Success!"
end

def view_event_details
  Event.all.each {|event| puts event.id.to_s + ") " + event.start.to_s + " - " + event.end_time.to_s + "\t" + event.name + "\t" + event.location}
  puts "Enter the number of the event to view it's notes"
  event = Event.find(gets.chomp.to_i)
  puts event.id.to_s + ") " + event.start.to_s + " - " + event.end_time.to_s + "\t" + event.name + "\t" + event.location
  event.notes.each{|note| puts note.description}
end

main_menu
