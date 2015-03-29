class CreateMarkets < ActiveRecord::Migration
  def change
    create_table :markets do |t|
      t.string :name, index: true, null: false, unique: true
      t.decimal :hour_opens, null: false
      t.decimal :hour_closes, null: false
      t.timestamps null: false
    end
  end
end
