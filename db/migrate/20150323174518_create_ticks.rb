class CreateTicks < ActiveRecord::Migration
  def change
    create_table :ticks do |t|
      t.references :sym, null: false, index: true
      t.datetime :time, null: false, index: true
      t.decimal :amount, null: false, index: true
      t.timestamps null: false
    end
  end
end
