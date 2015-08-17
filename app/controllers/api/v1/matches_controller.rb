class Api::V1::MatchesController < ApplicationController
    # before_action :current_user?
    
    def show
        user = User.find(params[:id])
        if user
            couple = user.couples.where.not(state: Couple::COUPLE_STATE_FINISH).first
            if couple
                response = {"state" => couple.state,
                            "result"=> couple.result,
                         "distance" => couple.distance,
                             "user" => {"state" => user.state},
                     "matched_user" => couple.matcher.to_hash}
                render json: response, statue: 200
            else
                response = {"user" => {"state" => user.state}}
                render json: response, status: 200
            end
        else
            render json: "", status: 404
        end
    end
    
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
            case params[:match][:event].to_i
            when User::EVENT_STOP
                user.stop
                render json: "", statue: 200
            when User::EVENT_START_MATCHING
                if user.update_attribute(:match_distance, params[:match][:distance])
                    user.start_matching
                    render json: "", statue: 200
                else
                    puts "#{Time.now}, error: #{user.errors.full_messages}"
                    render json: "", statue: 500
                end
            when User::EVENT_ACCEPT
                matched_user = User.find(params[:match][:matched_user_id])
                if matched_user
                    user.accept(matched_user)
                    render json: "", statue: 200
                else
                    render json: "", statue: 404
                end
            when User::EVENT_REJECT
                matched_user = User.find(params[:match][:matched_user_id])
                if matched_user
                    user.reject(matched_user)
                    render json: "", statue: 200
                else
                    render json: "", statue: 404
                end
            when User::EVENT_TIMEOUT
                user.timeout
                render json: "", statue: 200
            when User::EVENT_CLOSE
                matched_user = User.find(params[:match][:matched_user_id])
                if matched_user
                    user.close(matched_user)
                    render json: "", statue: 200
                else
                    render json: "", statue: 404
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
