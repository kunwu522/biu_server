class Device < ActiveRecord::Base
    belongs_to :user
    validates :phone, presence: true, uniqueness: true
end
