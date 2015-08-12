class CreateCouples < ActiveRecord::Migration
  def change
    create_table :couples do |t|
      t.integer :matched_id
      t.integer :matcher_id
      t.integer :state
      t.integer :result

      t.timestamps null: false
    end
    
    add_foreign_key :couples, :users, column: :matched_id
    add_foreign_key :couples, :users, column: :matcher_id
    add_index :couples, :matched_id
    add_index :couples, :matcher_id
    add_index :couples, [:matched_id, :matcher_id]
  end
end
