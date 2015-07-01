class Profile < ActiveRecord::Base
    belongs_to :user
    belongs_to :zodiac
    belongs_to :style
    belongs_to :sexuality
end
