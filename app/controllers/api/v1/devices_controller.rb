class Api::V1::DevicesController < ApplicationController
    before_action :current_user?
    
    def create
        device = Device.find_by(token: params[:device][:token])
        if device
            if device.user.id == params[:device][:user_id]
                render json: "", statue: 200
                return;
            else
                device.update_attribute(:user_id, params[:device][:user_id])
                render json: "", statue: 200
                return;
            end
        end
        
        device = Device.new(device_params)
        if device.save
            render json: "", statue: 200
        else
            render json: device.errors.fullmessages, statue: 500 
        end
    end
    
    def update
        user = User.find(params[:id])
        if user
            device = user.device
            if device
                device.update_attribute(:token, params[:device][:token])
                render json: "", statue: 200
            end
        else
            render json: "", statue: 500
        end
    end
    
    private
    def device_params
        params.require(:device).permit(:token, :user_id)
    end
end
