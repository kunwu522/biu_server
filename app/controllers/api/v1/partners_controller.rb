class Api::V1::PartnersController < ApplicationController
    before_action :current_user?
    
    api :POST, "/partners"
    param :partner, Hash, :desc => "user partner" do
        param :user_id, String, :desc => "user id"
        param :sexuality_ids, Array, :desc => "user partner sexualities"
        param :min_age, String, :desc => "user partner min age"
        param :max_age, String, :desc => "user partner max age"
        param :zodiac_ids, Array, :desc => "user partner zodiacs"
        param :style_ids, Array, :desc => "user partner styles"
    end
    def create
        partner = Partner.find_by(user_id: params[:partner][:user_id])
        if partner
            response = {"partner_id" => partner.id}
            render json: response, status: 200
            return;
        end
        @partner = Partner.new(partner_params)        
        if @partner.save
            Rails.logger.debug { "#{@partner.id} saved successful." }
            PreferencesCreateJob.perform_later(@partner.user)
            response = {"partner_id" => @partner.id}
            render json: response
        else
            puts "#{Time.now}, error: @#{partner.errors.full_messages}"
            render json: @partner.errors, status: 500
        end
    end
    
    api :PUT, "/partners/:id"
    param :partner, Hash, :desc => "user partner" do
        param :user_id, String, :desc => "user id"
        param :sexuality_ids, Array, :desc => "user partner sexualities"
        param :min_age, String, :desc => "user partner min age"
        param :max_age, String, :desc => "user partner max age"
        param :zodiac_ids, Array, :desc => "user partner zodiacs"
        param :style_ids, Array, :desc => "user partner styles"
    end
    def update
        @partner = Partner.find(params[:id])
        if @partner.update_attributes(partner_params)
            PreferencesUpdateJob.perform_later(@partner.user)
            response = {
                'id' => @partner.id
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
