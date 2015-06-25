class AddRoleToProfile < ActiveRecord::Migration
  def change
      add_reference :profiles, :sexuality, index: true
      add_foreign_key :profiles, :sexualities
  end
end
