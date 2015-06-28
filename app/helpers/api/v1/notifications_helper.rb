require 'houston'
module Api::V1::NotificationsHelper
    def push_match_notification(user1, user2)
        if !user1 && !user2
            return
        end
        
        alert = I18n.t('match_push_notification_alert')
        payload1 = user2.to_hash
        push_notification(user1.device.token, alert, payload1)
        
        payload2 = user1.to_hash
        push_notification(user2.device.token, alert, payload2)
    end
    
    def push_message_notification()
        
    end
    
    def push_notification(token, alert, payload, badge: 0, sound: "sosumi.aiff", category: "INVITE_CATEGORY", content_available: true)
        APN = Houston::Client.development
        APN.certificate = File.read("~/Work/Biu/certification/apple_push_notification.pem")
        
        notification = Houston::Notification.new(device: token)
        notification.alert = alert
        notification.badge = badge
        notification.sound = sound
        notification.category = category
        notification.content_available = content_available
        notification.custom_data = payload
        
        APN.push(notification)
    end
end
