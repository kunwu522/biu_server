class Api::V1::DevicesController < ApplicationController
    
    def create
        device = Device.new(device_params)
        if device.save
            render json: "", statue: 200
        else
            render json: device.errors.fullmessages, statue: 500 
        end
    end
    
    private
    def device_parames
        params.require(:device).permit(:token, :user_id)
    end
end
