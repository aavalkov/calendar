class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.string :name
    end
    change_table :events do |t|
      t.belongs_to :calendar
    end
  end
end
