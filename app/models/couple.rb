class Couple < ActiveRecord::Base
    belongs_to :matcher, class_name: "User"
    belongs_to :matched, class_name: "User"
    validates :matcher_id, presence: true
    validates :matched_id, presence: true
    
    before_save :default_values
    
    # Couple State
    COUPLE_STATE_START = 0
    COUPLE_STATE_COMMUNICATION = 1
    COUPLE_STATE_FINISH = 2
    
    # Couple Result
    COUPLE_RESULT_NONE = 0
    COUPLE_RESULT_DATE = 1
    COUPLE_RESULT_REJECT = 2
    COUPLE_RESULT_BEEN_REJECTED = 3
    COUPLE_RESULT_TIMEOUT = 4
    
    def chat
        self.update_attribute(:state, COUPLE_STATE_COMMUNICATION)
        self.update_attribute(:result, COUPLE_RESULT_DATE)
    end
    
    def date
        self.update_attribute(:state, COUPLE_STATE_FINISH)
        self.update_attribute(:result, COUPLE_RESULT_DATE)
    end
    
    def reject
        self.update_attribute(:state, COUPLE_STATE_FINISH)
        self.update_attribute(:result, COUPLE_RESULT_REJECT)
    end
    
    def been_rejected
        self.update_attribute(:state, COUPLE_STATE_FINISH)
        self.update_attribute(:result, COUPLE_STATE_BEEN_REJECTED)
    end
    
    def timeout
        self.update_attribute(:state, COUPLE_STATE_FINISH)
        self.update_attribute(:state, COUPLE_RESULT_TIMEOUT)
    end
    
    private
    def default_values
        self.state ||= COUPLE_STATE_START
        self.result ||= COUPLE_RESULT_NONE
    end 
end
