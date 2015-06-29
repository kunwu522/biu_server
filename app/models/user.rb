class User < ActiveRecord::Base
    before_save :default_values
        
    attr_accessor :remember_token
    has_one :profile, dependent: :destroy
    has_one :partner, dependent: :destroy
    has_many :devices, dependent: :destroy
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
                puts "age not match, user1: (name: #{self.username}, age: #{self_age}), user2: (name: #{user.username}, age: #{prefer_user_age})"
            end
        end
        return result
    end

    # Preferences
    def prefer(other_user)
        if other_user
            preferences.create(matcher_id: other_user.id)
        end
    end
    
    # Matched
    def User.matched(user1, user2)
        if !user1 || !user2
            return
        end
        user1_matched_count = user1.matched_count + 1
        user2_matched_count = user2.matched_count + 1
        user1.update_attribute(:state, STATE_MATCHED)
        user1.update_attribute(:matched_count, user1_matched_count)
        user2.update_attribute(:state, STATE_MATCHED)
        user2.update_attribute(:matched_count, user2_matched_count)
    end
    
    # Puts user info
    def user_detail_info
        puts "User id: #{self.id}, username: #{self.username}, latitude: #{self.latitude}, longitude: #{self.longitude} 
              Profile id: #{self.profile.id}, 
                    birthday: #{self.profile.birthday}, 
                    gender: #{self.profile.gender}
                    zodiac_id: #{self.profile.zodiac.id}, 
                    style_id: #{self.profile.style.id}, 
                    sexuality_id: #{self.profile.sexuality.id}
                <Partner id: #{self.partner.id}, 
                    min_age: #{self.partner.min_age}, 
                    max_age: #{self.partner.max_age},
                    sexualities: #{self.partner.sexualities.ids}
                    zodiacs: #{self.partner.zodiacs.ids}
                    styles: #{self.partner.styles.ids}"
    end
    
    def to_hash
        profile = nil
        if self.profile
            profile = {"profile_id" => self.profile.id,
                           "gender" => self.profile.gender,
                        "sexuality" => self.profile.sexuality.id,
                         "birthday" => self.profile.birthday,
                           "zodiac" => self.profile.zodiac.id,
                            "style" => self.profile.style.id}
        end
        
        partner = nil
        if @user.partner
            partner = {"partner_id" => self.partner.id,
                        "sexuality" => self.partner.sexualities.ids,
                          "min_age" => self.partner.min_age,
                          "max_age" => self.partner.max_age,
                       "zodiac_ids" => self.partner.zodiacs.ids,
                        "style_ids" => self.partner.styles.ids}
        end
        
        user = {"user_id" =>  @user.id, 
               "username" => @user.username, 
                "profile" => profile,
                "partner" => partner,
                  "token" => @user.device.token}
        return user
    end
    
    private
    def age(birthday)
        now = Time.now.utc.to_date
        now.year - birthday.year - (birthday.to_date.change(:year => now.year) > now ? 1 : 0)
    end
    
    def default_values
        self.state ||= STATE_COLSE
        self.matched_count ||= 0
        self.accepted_count ||= 0
        self.match_distance ||= 0
    end
                        
end
