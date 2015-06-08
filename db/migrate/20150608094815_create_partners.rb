class CreatePartners < ActiveRecord::Migration
  def change
    create_table :partners do |t|
      t.integer :min_age
      t.integer :max_age
      t.references :user, index: true, foreign_key: true
      t.references :sexuality, index: true, foreign_key: true
      t.timestamps null: false
    end
    
    create_table :partners_zodiacs, id: false do |t|
        t.belongs_to :partner, index: true
        t.belongs_to :zodiac, index: true
    end
    
    create_table :partners_styles, id: false do |t|
        t.belongs_to :partner, index: true
        t.belongs_to :style, index: true
    end
  end
end
