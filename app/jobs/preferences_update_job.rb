class PreferencesUpdateJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    # Do something later
    prefer_matching_users = user.prefer_matching_users - user.matchers
    if prefer_matching_users.count > 0
        prefer_matching_users.each do |prefer_matching_user|
             user.prefer(prefer_matching_user)
        end
    end
  end
end
