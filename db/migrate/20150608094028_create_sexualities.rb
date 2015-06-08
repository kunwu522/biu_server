class CreateSexualities < ActiveRecord::Migration
  def change
    create_table :sexualities do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
