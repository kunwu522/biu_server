include NotificationsHelper
require 'carrierwave/orm/activerecord'
class User < ActiveRecord::Base
    before_save :default_values
        
    attr_accessor :remember_token
    attr_accessor :updating_password
    has_one :profile, dependent: :destroy
    has_one :partner, dependent: :destroy
    has_one :device, dependent: :destroy
    has_many :preferences, class_name: "Preference", foreign_key: "user_id", dependent: :destroy
    has_many :candidates, through: :preferences, source: :candidate
    has_many :couples, class_name: "Couple", foreign_key: "matched_id", dependent: :destroy
    has_many :matchers, through: :couples, source: :matcher
    has_many :active_communications, class_name: "Communication", foreign_key: "sender_id", dependent: :destroy
    has_many :receivers, through: :active_communications, source: :receiver
    has_many :passive_communications, class_name: "Communication", foreign_key: "receiver_id", dependent: :destroy
    has_many :senders, through: :passive_communications, source: :sender
    mount_uploader :avatar_cycle, AvatarUploader
    mount_uploader :avatar_rectangle, AvatarUploader
    
    validates :username, presence: true, length: { maximum: 50 }

    VALID_PHONE_REGEX = /[0-9]{11}/
    validates :phone, length: {minimum: 11, maximum: 11},
                          uniqueness: true, format: { with: VALID_PHONE_REGEX }
    
    has_secure_password
    validates :password, length: { minimum: 8 }, :if => :should_validate_password? 
    
    STATE_IDLE = 0
    STATE_MATCHING = 1
    STATE_MATCHED = 2
    STATE_WAITING_ACCEPTED = 3
    STATE_COMMUNICATION = 4
    
    EVENT_STOP = 0
    EVENT_START_MATCHING = 1
    EVENT_ACCEPT = 2
    EVENT_REJECT = 3
    EVENT_TIMEOUT = 4
    EVENT_CLOSE = 5
    
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
    
    # return true if need to check passwork
    def should_validate_password?
        updating_password || new_record?
    end
    
    # Return prefer user
    def prefer_users
        if !self.partner || !self.profile
            return;
        end
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
        if !self.partner || !self.profile
            return;
        end
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

    # Preferences add
    def prefer(other_user)
        if other_user
            preferences.create(candidate_id: other_user.id)
        end
    end
    # Preferences remove
    def unprefer(other_user)
        if other_user
            preferences.find_by(candidate_id: other_user.id).destroy
        end
    end
    
    #Event
    def stop
        # if self.state == STATE_MATCHING
        #     update_attribute(:state, STATE_IDLE)
        # end
        update_attribute(:state, STATE_IDLE)
        if self.couple
            if self.couple.state == Couple::COUPLE_STATE_START
                self.couple.reject
            end
        end
    end
    
    def start_matching
        if self.state == STATE_IDLE
            update_attribute(:state, STATE_MATCHING)
        end
    end
    
    def match(other_user)
        if self.state == STATE_MATCHING
            matched_count = self.matched_count + 1
            self.update_attribute(:state, STATE_MATCHED)
            self.update_attribute(:matched_count, matched_count)
            self.couples.create(matcher_id: other_user.id, distance: distance(other_user))
            Rails.logger.debug { "Start to send notifiction to #{self.username}." }
            push_match_notification(self, other_user)
        end
    end
    
    def accept(matched_user)
        if self.state == STATE_MATCHED
            if matched_user.state == STATE_WAITING_ACCEPTED
                self.update_attribute(:state, STATE_COMMUNICATION)
                self.couple.chat
                self.start_communication(matched_user)
            else
                self.update_attribute(:state, STATE_WAITING_ACCEPTED)
            end
            matched_user.matched_user_accepted(self)
            push_matched_user_accepted_notification(matched_user)
        end
    end
    
    def reject(matched_user)
        if self.state == STATE_MATCHED || self.state == STATE_WAITING_ACCEPTED
            self.update_attribute(:state, STATE_MATCHING)
            self.couple.reject
            matched_user.matched_user_rejected
            push_matched_user_rejected_notification(matched_user)
        end
    end
    
    def matched_user_accepted(matched_user)
        if self.state == STATE_WAITING_ACCEPTED
            self.update_attribute(:state, STATE_COMMUNICATION)
            self.couple.chat
            start_communication(matched_user)
        end
    end
    
    def matched_user_rejected
        if self.state == STATE_WAITING_ACCEPTED || self.state == STATE_MATCHED
            self.update_attribute(:state, STATE_MATCHING)
            self.couple.been_reject
        end
    end
    
    def timeout
        if self.state == STATE_WAITING_ACCEPTED || self.state == STATE_MATCHED
            self.update_attribute(:state, STATE_MATCHING)
            self.couple.timeout
            self.matcher.couple.timeout
        end
    end
    
    def close(matched_user)
        if self.state == STATE_COMMUNICATION
            self.update_attribute(:state, STATE_IDLE)
            stop_communication(matched_user)
            self.couple.date
            if matched_user.state == STATE_COMMUNICATION
                push_user_close_conversation_notification(matched_user)
            end
        end
    end
    
    # Communications add
    def start_communication(receiver)
        if receiver
            self.update_attribute(:state, STATE_COMMUNICATION)
            self.active_communications.create(receiver_id: receiver.id)
        end
    end
    
    # Communication remove
    def stop_communication(receiver)
        if receiver
            self.active_communications.find_by(receiver_id: receiver.id).destroy
        end
    end
    
    # Mathcing close
    def matching_close
        self.update_attribute(:state, STATE_CLOSE)
    end
    
    # Matching
    def matching
        self.update_attribute(:state, STATE_MATCHING)
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
        if self.partner
            partner = {"partner_id" => self.partner.id,
                    "sexuality_ids" => self.partner.sexualities.ids,
                          "min_age" => self.partner.min_age,
                          "max_age" => self.partner.max_age,
                       "zodiac_ids" => self.partner.zodiacs.ids,
                        "style_ids" => self.partner.styles.ids}
        end
        
        device_token = nil
        if self.device
            device_token = self.device.token
        end
        
        user = {"user_id" => self.id,
                  "phone" => self.phone, 
               "username" => self.username,
               "open_id" => self.open_id,
               "avatar_url" => self.avatar_url,
   #     "avatar_cycle_url" => self.avatar_cycle.url,
   # "avatar_rectangle_url" => self.avatar_rectangle.url,
           "device_token" => device_token,
                "profile" => profile,
                "partner" => partner}
        return user
    end
    
    def couple
        self.couples.where.not(state: Couple::COUPLE_STATE_FINISH).first
    end
    
    private
    def age(birthday)
        now = Time.now.utc.to_date
        now.year - birthday.year - (birthday.to_date.change(:year => now.year) > now ? 1 : 0)
    end
    
    def distance(other_user)
        dtor = Math::PI / 180
        r = 6378.1 * 1000
        
        rlat1 = self.latitude * dtor
        rlong1 = self.longitude * dtor
        rlat2 = other_user.latitude * dtor
        rlong2 = other_user.longitude * dtor
        
        dlong = rlong1 - rlong2
        dlat = rlat1 - rlat2
        
        a = power(Math::sin(dlat/2), 2) + Math::cos(rlat1) * Math::cos(rlat2) * power(Math::sin(dlong/2), 2)
        c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
        d = r * c
        return d
    end
    
    def power(num, pow)
        num ** pow
    end
    
    def default_values
        self.state ||= STATE_IDLE
        self.matched_count ||= 0
        self.accepted_count ||= 0
        self.match_distance ||= 0
    end                   
end
