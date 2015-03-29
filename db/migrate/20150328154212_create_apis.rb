class CreateApis < ActiveRecord::Migration
  def change
    create_table :apis do |t|
      t.string :name, null: false, index: true
    end
  end
end
