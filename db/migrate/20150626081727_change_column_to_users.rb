class ChangeColumnToUsers < ActiveRecord::Migration
  def change
      change_column :users, :latitude, :decimal, :precision => 10, :scale => 6
      change_column :users, :longitude, :decimal, :precision => 10, :scale => 6
      add_column :users, :match_distance, :integer
  end
end
