class Api::V1::SessionsController < ApplicationController
    def create
        @user = User.find_by(phone: params[:session][:phone])
        if @user && @user.authenticate(params[:session][:password])
            Rails.logger.debug { "#{@user.email} log in..." }
            log_in @user
            remember @user
            respond_with :api, :v1, @user
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
end
