class Api::V1::UsersController < Api::V1::BaseController
    
    def show
        @user = User.find(params[:id])
        respond_with(@user)
    end
    
    def create
        @user = User.new(username: params[:username], email: params[:email], 
                        password: params[:password], password_confirmation: params[:password_confirmation])
        if @user.save
            user_response = {
                'id' => @user.id,
                'username' => @user.username
                'password' => @user.password
                'email' => @user.email
            }
            render json: user_response
        else
            render json: @user.errors, status: :unprocessable_entity
        end
    end
    
    def search
        @user = User.find_by(email: params[:email].downcase)
        respond_with(@user)
    end
    
    def login
        user = User.find_by(email: params[:email].downcase)
        if user && user.authenticate(params[:password])
            Rails.logger.debug { "#{user.email} log in..." }
            user_response = {
                'id' => @user.id,
                'username' => @user.username
                'password' => @user.password
                'email' => @user.email
            }
            render json: user_response
        else
            render json: @user.errors, status: :unprocessable_entity
    end
    
    private
  
        def user_params
            params.require(:user).permit(:username, :email, :password, :password_confirmation)
        end

        def query_params
            params.permit(:user_id, :username, :email, :password)
        end
  
end
