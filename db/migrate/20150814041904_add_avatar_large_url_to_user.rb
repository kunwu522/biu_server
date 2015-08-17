class AddAvatarLargeUrlToUser < ActiveRecord::Migration
  def change
    add_column :users, :avatar_large_url, :string
  end
end
