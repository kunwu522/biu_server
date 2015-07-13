class CreateCommunications < ActiveRecord::Migration
  def change
    create_table :communications do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :state, default: 0

      t.timestamps null: false
    end
    add_index :communications, :sender_id
    add_index :communications, :receiver_id
    add_index :communications, [:sender_id, :receiver_id], unique: true
  end
end
