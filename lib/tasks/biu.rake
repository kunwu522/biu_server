namespace :biu do
    desc "Matching Users"
    task :match => :environment do
        # Find user who waiting match
        matching_users = User.find_by(state: User::STATE_MATCHING)
        if matching_users.count > 0
            matching_users.each do |matching_user|
                prefer_users = matching_user.matchers.where(state: User::STATE_MATCHING)
                if prefer_users.count > 0
                    prefer_users_ids = "#{prefer_users.ids}".gsub(/\[/, "(").gsub(/\]/, ")")
                    matched_user =  user.find_by_sql("SELECT *, (6378.1 * acos(cos(radians(40.055220)) 
                                                                * cos(radians(latitude)) 
                                                                * cos(radians(longitude) - radians(116.291080)) 
                                                                + sin(radians(40.055220)) 
                                                                * sin(radians(latitude)))) AS distance 
                                                      FROM users 
                                                      WHERE users.id IN #{prefer_users_ids}  
                                                      HAVING distance < 1 
                                                      ORDER BY distance 
                                                      LIMIT 1")
                    if matched_user
                        puts "Match successed!! user1(id: #{matching_user.id}, name: #{matching_user.username}), user2(id: #{matched_user.id}, name: #{matched_user.username})"
                        User.matched(matching_user, matched_user)
                        matching_users.delete(matching_user)
                        matching_users.delete(matched_user)
                        
                        # TODO: send notification
                    end
                end
            end
        else
            puts "No user state is matching"
        end
    end
    
    desc "Scan Users to Preferences"
    task :scan_user => :environment do
        # scan user
        users = User.all
        users.each do |user|
            prefer_users = user.prefer_users
            if prefer_users.count > 0
                user.prefer(prefer_users)
            end
        end
    end
end
