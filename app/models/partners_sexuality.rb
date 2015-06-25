class PartnersSexuality < ActiveRecord::Base
    belongs_to :partner
    belongs_to :sexuality
end
