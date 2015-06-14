require 'carrierwave/orm/activerecord'
class Profile < ActiveRecord::Base
    belongs_to :user
    belongs_to :zodiac
    belongs_to :style

    mount_uploader :avatar, AvatarUploader
end
