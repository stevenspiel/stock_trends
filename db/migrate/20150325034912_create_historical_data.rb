class CreateHistoricalData < ActiveRecord::Migration
  def change
    create_table :historical_data do |t|
      t.references :sym, null: false, index: true
      t.date :date, null: false
      t.decimal :opening_price, index: true
      t.decimal :closing_price, index: true
      t.timestamps null: false
    end
  end
end
