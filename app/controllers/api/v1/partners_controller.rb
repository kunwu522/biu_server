class Api::V1::PartnersController < ApplicationController
    
    def create
        @partner = Partner.new(partner_params)
        zodiac_ids = params[:partner][:zodiac_ids]
        zodiac_ids.each do |zodiac_id|
            zodiac = Zodiac.find(zodiac_id)
            @partner.zodiacs << zodiac
        end
        style_ids = params[:partner][:style_ids]
        style_ids.each do |style_id|
            style = Style.find(style_id)
            @partner.styles << style
        end
        
        if @partner.save
            Rails.logger.debug { "#{@partner.id} saved successful." }
            response = {"partner_id" => @partner.id}
            render json: response
        else
            render plain: "create partner failed.", status: :internal_server_error
        end
    end
    
    def update
        
    end
    
    private
    def partner_params
        params.require(:partner).permit(:user_id, :sexuality_id, :min_age, :max_age, :zodiac_ids => [], :style_ids => [])
    end
end
