class Event <ActiveRecord::Base
  validates :name, :presence => true
  validates :start, :presence => true
  validate :end_time, :presence => true
  belongs_to :calendar
  has_many :notes, :as => :notable
  ActiveRecord::Base.default_timezone = :local

  def repeat_daily(times)
    (1..times-1).each do |number|
      new_start = (self.start.to_date + number).to_s + self.start.to_s.slice(-15..-1)
      new_end = (self.end_time.to_date + number).to_s + self.end_time.to_s.slice(-15..-1)
      self.dup.update(start: Time.parse(new_start).to_s, end_time: Time.parse(new_end).to_s)
    end
  end
end
