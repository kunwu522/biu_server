class Api::V1::SessionsController < ApplicationController
    def create
        @user = User.find_by(phone: params[:phone])
        if !@user
            error = {"error_message" => I18n.t('phone_not_exist')}
            render json: error, status: 404
            return
        end
        if @user.authenticate(params[:password])
            Rails.logger.debug { "#{@user.id} log in..." }
            log_in @user
            remember @user
            response = {"user" => @user.to_hash}
            render json: response, status: 201
        else
            error = {"error_message" => I18n.t('phone_number_password_not_match')}
            render json: error, status: 401
        end
    end
    
    def create_third_party
        @user = User.find_by(open_id: params[:user][:open_id])
        if @user
            log_in @user
            remember @user
            if !@user.avatar_url
                @user.update_attribute(:avatar_url, params[:user][:avatar_url])
                @user.update_attribute(:avatar_large_url, params[:user][:avatar_large_url])
            end
            @user.update_attribute(:username, params[:user][:username])
            render json: {"user" => @user.to_hash}, status: 201
        else
            @user = User.new(username: params[:user][:username], open_id: params[:user][:open_id], avatar_url: params[:user][:avatar_url])
            if @user.save(validate: false)
                log_in @user
                remember @user
                if (ENV['RAILS_ENV'] == 'production')
                    system("sudo ejabberdctl register #{@user.open_id} biulove.com #{@user.open_id}")
                else
                    puts "sudo ejabberdctl register #{@user.open_id} biulove.com #{@user.open_id}"
                end
                response = {"user" => {"user_id" => @user.id,
                                       "open_id" => @user.open_id, 
                                       "username" => @user.username,
                                       "avatar_url" => @user.avatar_url,
                                       "avatar_large_url" => @user.avatar_large_url}}
                render json: response, status: 201
            else
                render json: "", status: 500
            end
        end
    end
    
    def destroy
        log_out
        response = {'status' => 'ok',
                    'message' => "user has log out"}
        render json: response, status: :ok
    end
    
    private
    def third_party_login_params
        params.require(:user).permit(:open_id, :avatar_url, :username)
    end
    
    def build_respones
        profile = nil
        if @user.profile
            profile = {"profile_id" => @user.profile.id,
                           "gender" => @user.profile.gender,
                         "birthday" => @user.profile.birthday,
                           "zodiac" => @user.profile.zodiac.id,
                            "style" => @user.profile.style.id}
        end
        
        partner = nil
        if @user.partner
            zodiac_ids = [];
            @user.partner.zodiacs.each do |zodiac|
                zodiac_ids << zodiac.id
            end
            style_ids = [];
            @user.partner.styles.each do |style|
                style_ids << style.id
            end
            partner = {"partner_id" => @user.partner.id,
                        "sexuality_ids" => @user.partner.sexualities.ids,
                          "min_age" => @user.partner.min_age,
                          "max_age" => @user.partner.max_age,
                       "zodiac_ids" => zodiac_ids,
                        "style_ids" => style_ids}
        end
        
        user = {"user_id" =>  @user.id, 
                "username" => @user.username,
                "avatar_cycle_url" => @user.avatar_cycle.url,
                "avatar_rectangle_url" => @user.avatar_rectangle.url,
                "profile" => profile,
                "partner" => partner}
        response = {"user" => user}
    end
end
