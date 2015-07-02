class Api::V1::MatchesController < ApplicationController
    before_action :current_user?
    
    def update
        user = User.find(params[:id])
        if !user
            error = {"error_message" => I18n.t('user_not_exist')}
            render json: error, statue: 404
        end
        
        if user.update_attributes(location_params)
            render json: "", statue: 200
        else
            puts "#{Time.now}, error: #{user.errors.full_messages}"
            render json: user.errors.full_messages, statue: 500
        end
    end
    
    def match
        user = User.find(params[:id])
        if user
            case params[:match][:state]
            when User::STATE_CLOSE
                user.matching_close
                render json: "", statue: 200
            when User::STATE_MATCHING
                if user.update_attribute(:match_distance, params[:match][:distance])
                    user.matching
                    render json: "", statue: 200
                else
                    puts "#{Time.now}, error: #{user.errors.full_messages}"
                    render json: "", statue: 500
                end
            else
                render json: "", statue: 400
            end
        else
            render json: "", statue: 404
        end
    end
    
    private
    def location_params
        params.require(:location).permit(:latitude, :longitude)
    end
end
