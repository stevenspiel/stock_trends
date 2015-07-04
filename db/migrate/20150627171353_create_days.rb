class CreateDays < ActiveRecord::Migration
  def change
    create_table :days do |t|
      t.references :sym, index: true, null: false
      t.date :date, null: false
      t.timestamps null: false
    end

    add_index :days, :date
  end
end
