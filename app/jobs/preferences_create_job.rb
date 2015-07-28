class PreferencesCreateJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    # Do something later
    if user.partner && user.profile
        prefer_users = user.prefer_users
        if prefer_users.count > 0
            prefer_users.each do |prefer_matching_user|
                 user.prefer(prefer_matching_user)
            end
        end
    end
  end
end
