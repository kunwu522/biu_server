class Api::V1::SessionsController < ApplicationController
    def create
        @user = User.find_by(phone: params[:session][:phone])
        if @user && @user.authenticate(params[:session][:password])
            Rails.logger.debug { "#{@user.id} log in..." }
            log_in @user
            remember @user
            render json: build_respones, status: 201
        else
            error = {"error_message" => I18n.t('phone_number_password_not_match')}
            render json: error, status: 401
        end
    end
    
    def destroy
        log_out
        response = {'status' => 'ok',
                    'message' => "user has log out"}
        render json: response, status: :ok
    end
    
    private
    def build_respones
        profile = nil
        if @user.profile
            profile = {"profile_id" => @user.profile.id,
                           "gender" => @user.profile.gender,
                         "birthday" => @user.profile.birthday,
                           "zodiac" => @user.profile.zodiac.id,
                            "style" => @user.profile.style.id,
                           "avatar" => @user.profile.avatar.url}
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
                        "sexuality" => @user.partner.sexuality.id,
                          "min_age" => @user.partner.min_age,
                          "max_age" => @user.partner.max_age,
                       "zodiac_ids" => zodiac_ids,
                        "style_ids" => style_ids}
        end
        
        user = {"user_id" =>  @user.id, 
                "username" => @user.username, 
                "profile" => profile,
                "partner" => partner}
        response = {"user" => user}
    end
end
