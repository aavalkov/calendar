class CreateToDosAndNotes < ActiveRecord::Migration
  def change
    create_table :todos do |t|
      t.string :description
      t.timestamps
    end

    create_table :notes do |t|
      t.string :description
      t.references :notable, polymorphic: true
      t.timestamps
    end
  end
end
