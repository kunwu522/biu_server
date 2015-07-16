class AddIndexToDevices < ActiveRecord::Migration
  def change
      add_index :devices, [:token, :user_id], unique: true
  end
end
