class CreatePartnersSexualities < ActiveRecord::Migration
  def change
    remove_reference :partners, :sexuality, index: true, foreign_key: true
    create_table :partners_sexualities do |t|
        t.belongs_to :partner, index: true
        t.belongs_to :sexuality, index: true
    end
    add_index :partners_sexualities, [:partner_id, :sexuality_id], unique: true
  end
end
