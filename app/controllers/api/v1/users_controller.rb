class Api::V1::UsersController < ApplicationController
    
    def show
        @user = User.find(params[:id])
        respond_with(@user)
    end
    
    def create
        @user = User.new(user_params)
        if @user.save
            log_in @user
            user_response = {
                'user_id' => @user.id,
                'username' => @user.username,
                'phone' => @user.phone
            }
            render json: user_response
        else
            render json: @user.errors.full_messages, status: :unprocessable_entity
        end
    end
    
    def search
        @user = User.find_by(email: params[:email].downcase)
        respond_with(@user)
    end
    
    def update
        user = User.find(params[:id])
        if user.update_attribute(user_params)
            response_with(user)
        else
            render json: user.errors, status: :unprocessable_entity
        end
    end
    
    private
    def user_params
        params.require(:user).permit(:username, :phone, :password, :password_confirmation)
    end

    def query_params
        params.permit(:user_id, :username, :email, :password)
    end
  
end
