class CreateZodiacs < ActiveRecord::Migration
  def change
    create_table :zodiacs do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
