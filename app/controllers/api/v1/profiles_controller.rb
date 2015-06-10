class Api::V1::ProfilesController < ApplicationController
    before_action :current_user?
    
    def show
        @profile = Profile.find(params[:id])
        respond_with(@profile)
    end
    
    def create
        @profile = Profile.new(profile_params)
        if @profile.save
            Rails.logger.debug { "#{@profile.id} save success." }
            response = {
                'profile_id' => @profile.id
            }
            render json: response
        else
            render json: @profile.errors, status: :unprocessable_entity
        end
    end
    
    def update
        @profile = Profile.find(params[:id])
        if @profile.update_attributes(profile_params)
            response = {
                'id' => @profile.id
            }
            render json: response
        else
            render json: @profile.errors, status: :unprocessable_entity
        end
    end
    
    def upload
        profile = Profile.find(params[:id])
        profile.avator = params[:file]
    end
    
    private
    def profile_params
        params.require(:profile).permit(:birthday, :gender, :user_id, :zodiac_id, :style_id)
    end
end
