class ChangeColumnAvatarTo < ActiveRecord::Migration
  def change
      rename_column :profiles, :avatar, :avatar_cycle
  end
end
