class CreateFavoriteSyms < ActiveRecord::Migration
  def change
    create_table :favorite_syms do |t|
      t.references :user, index: true, null: false
      t.references :sym, index: true, null: false

      t.timestamps null: false
    end

    remove_column :syms, :favorite
  end
end
