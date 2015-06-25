class User < ActiveRecord::Base
    before_save :default_values
        
    attr_accessor :remember_token
    has_one :profile
    has_one :partner
    has_many :preferences, class_name: "Preference", foreign_key: "matched_id", dependent: :destroy
    has_many :matchers, through: :preferences, source: :matcher
    
    validates :username, presence: true, length: { maximum: 50 }

    VALID_PHONE_REGEX = /[0-9]{11}/
    validates :phone, presence: true, length: {minimum: 11, maximum: 11},
                          uniqueness: true, format: { with: VALID_PHONE_REGEX }
    
    has_secure_password
    validates :password, length: { minimum: 8 }
    
    STATE_COLSE = 0
    STATE_MATCHING = 1
    STATE_MATCHED = 2
    
    # Return the hash digest of the given string
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                          BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end
    
    # Return a random token.
    def User.new_token
        SecureRandom.urlsafe_base64
    end
    
    # Remember a user in the database for use in persistent sessions.
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end
    
    # Returns true if the given token matches the digest
    def authenticated?(remember_token)
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end
    
    # Forgets a user
    def forget
        update_attribute(:remember_digest, nil)
    end
    
    # Return prefer user
    def prefer_users
        users = User.joins(:profile, partner:[:sexualities, :zodiacs, :styles]).where(profiles:{sexuality_id: self.partner.sexualities.ids, zodiac_id: self.partner.zodiacs.ids, style_id: self.partner.styles.ids}, sexualities:{id: self.profile.sexuality.id}, zodiacs:{id: self.profile.zodiac.id}, styles:{id: self.profile.style.id})
        result = Array.new
        self_age = age(self.profile.birthday)
        users.each do |user|
            prefer_user_age = age(user.profile.birthday)
            if (self_age >= user.partner.min_age && self_age <= user.partner.max_age && prefer_user_age >= self.partner.min_age && prefer_user_age <= self.partner.max_age)
                result << user
            else
                puts "age not match username: #{user.username}, age: #{prefer_user_age}"
            end
        end
        return result
    end
    
    # Return prefer user who state is matching
    def prefer_matching_users
        users = User.joins(:profile, partner:[:sexualities, :zodiacs, :styles]).where(state: User::STATE_MATCHING, profiles:{sexuality_id: self.partner.sexualities.ids, zodiac_id: self.partner.zodiacs.ids, style_id: self.partner.styles.ids}, sexualities:{id: self.profile.sexuality.id}, zodiacs:{id: self.profile.zodiac.id}, styles:{id: self.profile.style.id})
        result = Array.new
        self_age = age(self.profile.birthday)
        users.each do |user|
            prefer_user_age = age(user.profile.birthday)
            if (self_age >= user.partner.min_age && self_age <= user.partner.max_age && prefer_user_age >= self.partner.min_age && prefer_user_age <= self.partner.max_age)
                result << user
            else
                puts "age not match username: #{user.username}, age: #{prefer_user_age}"
            end
        end
        return result
    end

    # Preferences
    def prefer(other_user)
        preferences.create(matcher_id: other_user.id)
    end
    
    # Matched
    def User.matched(user1, user2)
        user1_matched_count = user1.matched_count++
        user2_matched_count = user2.matched_count++
        user1.update_attributes(state: STATE_MATCHED, matched_count: user1_matched_count)
        user2.update_attributes(state: STATE_MATCHED, matched_count: user2_matched_count)
    end
    
    private
    def age(birthday)
        now = Time.now.utc.to_date
        now.year - birthday.year - (birthday.to_date.change(:year => now.year) > now ? 1 : 0)
    end
    
    def default_values
        self.state ||= STATE_COLSE
    end
                        
end
