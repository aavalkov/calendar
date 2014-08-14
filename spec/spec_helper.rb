require 'bundler/setup'
Bundler.require(:default, :test)
Dir[File.dirname(__FILE__) + '/../lib/*.rb'].each { |file| require file }

database_configurations = YAML::load(File.open('./db/config.yml'))
test_configuration = database_configurations['test']
ActiveRecord::Base.establish_connection(test_configuration)


RSpec.configure do |config|
  config.before(:each) do
    Event.all.each { |event| event.destroy }
    Calendar.all.each { |calendar| calendar.destroy }
  end
end
