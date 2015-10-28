class Api::V1::MatchesController < ApplicationController
    # before_action :current_user?
    
    api :GET, "/match/:id", "Get match info"
    param :state, :number, :desc => "matched state"
    param :result, :number, :desc => "matched result"
    param :distance, :number, :desc => "distance of two matched user"
    param :user, Hash, :desc => "user state" do
        param :state, :number, :desc => "user state" 
    end
    param :matched_user, Hash, :desc => "matched user info" do
        param :user_id, :number, :desc => "user id"
        param :phone, String, :desc => "user phone number"
        param :username, String, :desc => "username"
        param :open_id, String, :desc => "id for login with wechat or weibo"
        param :avatar_url, String, :desc => "avatar url"
        param :avatar_large_url, String, :desc => "avatar large url"
        param :state, :number, :desc => "user state"
        param :device_token, String, :desc => "device token"
        param :profile, Hash, :desc => "user profile" do
            param :profile_id, :number, :desc => "profile id"
            param :gender, :number, :desc => "user gender"
            param :sexuality, :number, :desc => "user sexuality"
            param :birthday, :number, :desc => "user birthday"
            param :zodiac, :number, :desc => "user zodiac"
            param :style, :number, :desc => "user style"
        end
        param :partner, Hash, :desc => "user partner" do
            param :partner_id, :number, :desc => "partner id"
            param :sexuality_ids, Array, :desc => "user partner sexualities"
            param :min_age, :number, :desc => "user partner min age"
            param :max_age, :number, :desc => "user partner max age"
            param :zodiac_ids, Array, :desc => "user partner zodiacs"
            param :style_ids, Array, :desc => "user partner styles"
        end
    end
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
    
    api :GET, "/location/:id"
    param :latitude, :number, :desc => "latitude"
    param :longitude, :number, :desc => "longitude"
    def show_location
        user = User.find(params[:id])
        if user
            response = {"location" => {"latitude" => user.latitude,
                                       "longitude" => user.longitude}}
            render json: response, status: 200
        else
            render json: "", status: 404
        end
    end
    
    api :PUT, "/location/:id"
    param :id, :number, :desc => "user id"
    param :location, Hash, :desc => "location" do
        param :latitude, :number, :desc => "latitude"
        param :longitude, :number, :desc => "longitude"
    end
    def update
        user = User.find(params[:id])
        if !user
            error = {"error_message" => I18n.t('user_not_exist')}
            render json: error, statue: 404
        end
        
        if (user.update_attribute(:latitude, params[:location][:latitude]) \
            && user.update_attribute(:longitude, params[:location][:longitude]))
            render json: "", statue: 200
        else
            Rails.logger.debug { "#{Time.now}, error: #{user.errors.full_messages}" }
            render json: user.errors.full_messages, statue: 500
        end
    end
    
    api :PUT, "/match/:id"
    param :id, :number, :desc => "user id"
    param :match, Hash, :desc => "match info" do
        param :event, :number, :desc => "event"
        param :distance, :number, :desc => "distance"
        param :matched_user_id, :number, :desc => "matched user id"
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
                    user.close(nil)
                    render json: "", statue: 200
                end
            when User::EVENT_START_NAVIGATION
                matched_user = User.find(params[:match][:matched_user_id])
                if matched_user
                    user.start_navigation(matched_user)
                    render json: "", statue: 200
                else
                    render json: "", statue: 404
                end
            when User::EVENT_STOP_NAVIGATION
                matched_user = User.find(params[:match][:matched_user_id])
                if matched_user
                    user.stop_navigation(matched_user)
                    render json: "", status: 200
                else
                    render json: "", status: 404
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
