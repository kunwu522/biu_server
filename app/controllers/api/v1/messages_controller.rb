include NotificationsHelper
class Api::V1::MessagesController < ApplicationController
    
    api :POST, "/messages"
    param :message, Hash, :desc => "message info" do
        param :from, :number, :desc => "from user id"
        param :to, :number, :desc => "to user id"
        param :type, :number, :desc => "text of image"
        param :content, String, :desc => "content"
    end
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
