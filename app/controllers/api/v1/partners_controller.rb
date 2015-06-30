class Api::V1::PartnersController < ApplicationController
    
    def create
        @partner = Partner.new(partner_params)        
        if @partner.save
            Rails.logger.debug { "#{@partner.id} saved successful." }
            PreferencesUpdateJob.perform_later(@partner.user)
            response = {"partner_id" => @partner.id}
            render json: response
        else
            puts "#{Time.now}, error: @#{partner.errors.full_messages}"
            render json: @partner.errors, status: 500
        end
    end
    
    def update
        @partner = Partner.find(params[:id])
        if @partner.update_attributes(partner_params)
            PreferencesUpdateJob.perform_later(@partner.user)
            response = {
                'id' => @profile.id
            }
            render json: response
        else
            puts "#{Time.now}, error: #{@partner.errors.full_messages}"
            render json: @partner.errors, status: 500
        end
    end
    
    private
    def partner_params
        params.require(:partner).permit(:user_id, :min_age, :max_age, :sexuality_ids => [], :zodiac_ids => [], :style_ids => [])
    end
end
