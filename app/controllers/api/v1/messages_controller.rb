include NotificationsHelper
class Api::V1::MessagesController < ApplicationController
    def create
        from_id = params[:message][:from]
        to_id = params[:message][:to]
        type = params[:message][:type]
        content = params[:message][:content]
        
        if from_id && to_id && type && content
            sender = User.find(from_id)
            receiver = User.find(to_id)
            if !sender || !receiver
                render json: "", status: 500
                return;
            end
            push_message_notification(sender, receiver, type, content)
            render json: "", status: 200
        else
            render json: "", status: 404
        end
    end
end
