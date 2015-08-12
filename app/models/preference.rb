class Preference < ActiveRecord::Base
    belongs_to :candidate, class_name: "User"
    belongs_to :user, class_name: "User"
    validates :candidate_id, presence: true
    validates :user_id, presence: true
end
