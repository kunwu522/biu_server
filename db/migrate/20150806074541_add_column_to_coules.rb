class AddColumnToCoules < ActiveRecord::Migration
  def change
      add_column :couples, :distance, :integer
  end
end
