class PreferencesUpdateJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    # Do something later
    if !user.partner || !user.profile
        return
    end
    
    if !user.prefer_users
        Rails.logger.debug { "There is no prefer users for user: #{user.id} #{user.username}" }
        return
    end
    prefer_users = user.prefer_users - user.candidates
    if prefer_users.count > 0
        prefer_users.each do |prefer_matching_user|
             user.prefer(prefer_matching_user)
        end
    end
  end
end
