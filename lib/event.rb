class Event <ActiveRecord::Base
  validates :name, :presence => true
  validates :start, :presence => true
  validate :end_time, :presence => true
  belongs_to :calendar
  ActiveRecord::Base.default_timezone = :local
end
