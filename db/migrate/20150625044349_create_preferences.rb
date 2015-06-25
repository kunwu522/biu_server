class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.integer :matched_id
      t.integer :matcher_id

      t.timestamps null: false
    end
    add_index :preferences, :matched_id
    add_index :preferences, :matcher_id
    add_index :preferences, [:matched_id, :matcher_id], unique: true
  end
end
