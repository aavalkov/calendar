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
  def repeat_weekly(times)
    (1..times-1).each do |number|
      new_start = (self.start.to_date + number*7).to_s + self.start.to_s.slice(-15..-1)
      new_end = (self.end_time.to_date + number*7).to_s + self.end_time.to_s.slice(-15..-1)
      self.dup.update(start: Time.parse(new_start).to_s, end_time: Time.parse(new_end).to_s)
    end
  end
  def repeat_monthly(times)
    current_month = self.start.to_date
    current_month_end = self.end_time.to_date
    (1..times-1).each do |number|
      new_start = (current_month.next_month).to_s + self.start.to_s.slice(-15..-1)
      new_end = (current_month_end.next_month).to_s + self.end_time.to_s.slice(-15..-1)
      self.dup.update(start: Time.parse(new_start).to_s, end_time: Time.parse(new_end).to_s)
      current_month = current_month.next_month
    end
  end
end
