class AddColumnToUser < ActiveRecord::Migration
  def change
      add_column :users, :open_id, :string
      add_column :users, :avatar_url, :string
  end
end
