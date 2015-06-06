class AddColumeToProfile < ActiveRecord::Migration
  def change
        add_column :profiles, :gender, :integer
        add_reference :profiles, :zodiac, index: true
        add_foreign_key :profiles, :zodiacs
        add_reference :profiles, :style, index: true
        add_foreign_key :profiles, :styles
  end
end