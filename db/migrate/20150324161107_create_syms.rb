class CreateSyms < ActiveRecord::Migration
  def change
    create_table :syms do |t|
      t.references :market, null: false, index: true
      t.references :historical_api, index: true
      t.references :intraday_api, index: true
      t.string :name, null: false, index: true, unique: true
      t.string :full_name, index: true
      t.decimal :current_price, index: true
      t.decimal :volatility, index: true
      t.datetime :last_updated_tick_time
      t.boolean :currently_collecting_data, default: false
      t.boolean :showing_patterns
      t.boolean :historical_data_logged
      t.boolean :intraday_log_error
      t.timestamps null: false
    end
  end
end
