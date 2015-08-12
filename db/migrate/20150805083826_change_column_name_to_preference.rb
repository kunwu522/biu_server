class ChangeColumnNameToPreference < ActiveRecord::Migration
  def change
      rename_column :preferences, :matched_id, :user_id
      rename_column :preferences, :matcher_id, :candidate_id
  end
end
