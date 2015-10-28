class Api::V1::DevicesController < ApplicationController
    before_action :current_user?
    
    api :POST, '/devices', "Create device token"
    param :device, Hash, :desc => "device info" do
        param :user_id, String, :desc => "user id", :required => true
        param :token, String, :desc => "device token", :required => true
    end
    def create
        device = Device.find_by(user_id: params[:device][:user_id])
        if device
            device.update_attribute(:token, params[:device][:token])
            render json: "", statue: 200
            return;
        end
        
        device = Device.new(device_params)
        if device.save
            render json: "", statue: 200
        else
            render json: device.errors.fullmessages, statue: 500 
        end
    end
    
    api :PUT, '/devices/:id', "Update device token"
    param :id, :number
    param :device, Hash, :desc => "device info" do
        param :token, String, :desc => "device token", :required => true
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
