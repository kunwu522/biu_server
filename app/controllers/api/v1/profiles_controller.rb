class Api::V1::ProfilesController < ApplicationController
    # before_action :current_user?
    
    def show
        @profile = Profile.find(params[:id])
        respond_with(@profile)
    end
    
    def create
        profile = Profile.find_by(user_id: params[:profile][:user_id])
        if profile
            render json: "", status: 200
            return;
        end
        @profile = Profile.new(profile_params)
        if @profile.save
            Rails.logger.debug { "#{@profile.id} save success." }
            PreferencesUpdateJob.perform_later(@profile.user)
            response = {
                'profile_id' => @profile.id
            }
            render json: response, status: 200
        else
            render json: @profile.errors, status: :unprocessable_entity
        end
    end
    
    def update
        @profile = Profile.find(params[:id])
        if @profile.update_attributes(profile_params)
            PreferencesUpdateJob.perform_later(@profile.user)
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
        puts "file: #{params[:avatar]}"
        attribute = params[:shape] == 'rect' ? 'avatar_rectangle' : 'avatar_cycle'
        if profile.update_attribute(attribute, params[:avatar])
            puts "rectangle avatar url: #{profile.avatar_rectangle.url}"
            puts "cycle avatar url: #{profile.avatar_cycle.url}"
            response = {"rectangle_url" => profile.avatar_rectangle.url,
                        "cycle_url" => profile.avatar_cycle.url}
            render json: response, status: 200
        else
            error = {"error_message" => I18n.t('upload_failed')}
            render json: error, status: 500
        end
    end
    
    def download
        profile = Profile.find(params[:id])
        if !profile
            render json: "", status: 404
            return
        end
        
        if params[:shape] == 'rect'
            if profile.avatar_rectangle
                send_file profile.avatar_rectangle.url, type: 'image/jpg', disposition: 'inline'
            else
                render json: "", status: 404
            end
            return
        end
        
        if params[:shape] == 'cycle'
            if profile.avatar_cycle
                send_file profile.avatar_cycle.url, type: 'image/jpg', disposition: 'inline'
            else
                render json: "", status: 404
            end
            return
        end
        render json: "", status: 404
    end
    
    private
    def profile_params
        params.require(:profile).permit(:birthday, :gender, :sexuality_id, :user_id, :zodiac_id, :style_id)
    end
end
