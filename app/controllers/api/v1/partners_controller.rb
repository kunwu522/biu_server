class Api::V1::PartnersController < ApplicationController
    
    def create
        @partner = Partner.new(partner_params)
        if @partner.save
            Rails.logger.debug { "#{@partner.id} saved successful." }
            response = {"partner_id" => @partner.id}
            render json: response
        else
            render plain: "create partner failed.", status: :internal_server_error
        end
    end
    
    private
    def partner_params
        params.require(:partner).permit(:user_id, :sexuality_id, :min_age, :max_age, :zodiac_ids => [:zodiac_id], :style_ids => [:style_id])
    end
end
