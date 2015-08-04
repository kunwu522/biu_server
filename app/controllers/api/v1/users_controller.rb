class Api::V1::UsersController < ApplicationController
    before_action :current_user?, except: [:create,:forgot_password]
    
    def show
        @user = User.find(params[:id])
        render json: @user.to_hash, status: 200
    end
    
    def create
        user = User.find_by(phone: params[:user][:phone])
        if user
            puts "#{user.phone} is exist"
            error = {"error_message" => I18n.t('phone_exist')}
            render json: error, status: 500
            return;
        end
        @user = User.new(user_params)
        if @user.save
            log_in @user
            if (ENV['RAILS_ENV'] == 'production')
                system("sudo ejabberdctl register #{@user.phone} biulove.com #{params[:user][:password]}")
            end
            user_response = {"user" => {"user_id" => @user.id,
                                        "username" => @user.username,
                                        "phone" => @user.phone}}
            render json: user_response, status: 200
        else
            render json: @user.errors.full_messages, status: :unprocessable_entity
        end
    end
    
    def search
        @user = User.find_by(email: params[:email].downcase)
        respond_with(@user)
    end
    
    def forgot_password
        user = User.find_by(params[:phone])
        if !user
            error = {"error_message" => I18n.t('user_not_exist')}
            render json: error, status: 404
            return
        end
        
        if user.update_attributes(update_password_params)
            if (ENV['RAILS_ENV'] == 'production')
                system("sudo ejabberdctl unregister #{user.phone} biulove.com")
                system("sudo ejabberdctl register #{user.phone} biulove.com #{params[:user][:password]}")
            end
            puts "password reset: #{params[:user][:password]}"
            render json: "", status: 200
        else
            render json: user.errors.full_messages, status: 500
        end
    end
    
    def update
        user = User.find(params[:id])
        if user.update_attribute(user_params)
            response_with(user)
        else
            render json: user.errors, status: :unprocessable_entity
        end
    end
    
    def upload
        user = User.find(params[:id])
        puts "file: #{params[:avatar]}"
        attribute = params[:shape] == 'rect' ? 'avatar_rectangle' : 'avatar_cycle'
        if user.update_attribute(attribute, params[:avatar])
            puts "rectangle avatar url: #{user.avatar_rectangle.url}"
            puts "cycle avatar url: #{user.avatar_cycle.url}"
            response = {"rectangle_url" => user.avatar_rectangle.url,
                        "cycle_url" => user.avatar_cycle.url}
            render json: response, status: 200
        else
            error = {"error_message" => I18n.t('upload_failed')}
            render json: error, status: 500
        end
    end
    
    def download
        user = User.find(params[:id])
        if !user
            render json: "", status: 404
            return
        end
        # if File.exist?(params[:url])
        #     send_file params[:url], type: 'image/jpg', disposition: 'inline'
        # else
        #     render json: "", status: 404
        # end
        
        if params[:shape] == 'rect'
            if user.avatar_rectangle.url
                send_file user.avatar_rectangle.url, type: 'image/jpg', disposition: 'inline'
            else
                render json: "", status: 404
            end
            return
        end

        if params[:shape] == 'cycle'
            if user.avatar_cycle.url
                send_file user.avatar_cycle.url, type: 'image/jpg', disposition: 'inline'
            else
                render json: "", status: 404
            end
            return
        end
        render json: "", status: 404
    end
    
    private
    def user_params
        params.require(:user).permit(:username, :phone, :password, :password_confirmation, :email)
    end
    
    def update_password_params
        params.require(:user).permit(:password, :password_confirmation)
    end

    def query_params
        params.permit(:user_id, :username, :email, :password)
    end
  
end
