class AddColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :state, :integer
    add_column :users, :matched_count, :integer
    add_column :users, :accepted_count, :integer
  end
end
