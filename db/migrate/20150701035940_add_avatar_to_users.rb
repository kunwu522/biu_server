class AddAvatarToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar_rectangle, :string
    add_column :users, :avatar_cycle, :string
    remove_column :profiles, :avatar_rectangle, :string
    remove_column :profiles, :avatar_cycle, :string
  end
end
