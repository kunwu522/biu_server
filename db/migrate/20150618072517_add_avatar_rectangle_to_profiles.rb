class AddAvatarRectangleToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :avatar_rectangle, :string
  end
end
