class User < ActiveRecord::Base
    attr_accessor :remember_token
    has_one :profile
    has_one :partner
    
    validates :username, presence: true, length: { maximum: 50 }

    VALID_PHONE_REGEX = /[0-9]{11}/
    validates :phone, presence: true, length: {minimum: 11, maximum: 11},
                          uniqueness: true, format: { with: VALID_PHONE_REGEX }
    
    has_secure_password
    validates :password, length: { minimum: 8 }
    
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
                        
end
