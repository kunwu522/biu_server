class Zodiac < ActiveRecord::Base
    has_and_belongs_to_many :partners, join_table: "partners_zodiacs", foreign_key: "partner_id"
end
