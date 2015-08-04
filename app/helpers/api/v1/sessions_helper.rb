module Api::V1::SessionsHelper
    # Log in the given user.
    def log_in(user)
        session[:user_id] = user.id
    end
    
    # Log out the current user
    def log_out
        forget(current_user)
        session.delete(:user_id)
        @current_user.device.destroy
        @current_user = nil;
    end
    
    # Remember a user in a persistent session.
    def remember(user)
        user.remember
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end
    
    # Forgets a persistent session.
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end
    
    # Return current login user
    def current_user
        if (user_id = session[:user_id])
            @current_user ||= User.find_by(id: user_id)
        elsif (user_id = cookies.signed[:user_id])
            user = User.find_by(id: user_id)
            if user && user.authenticated?(cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end
    
    # Return true if the user is logged in
    def logged_in?
        !@current_user.nil?
    end
    
    # return 401 if current_uesr is nil
    def current_user?
        current_user
        if logged_in?
            Rails.logger.debug { "#{current_user.username} logged in." }
            return true 
        else
            Rails.logger.debug { "no current user..." }
            render plain: "401 authentication failed", status: 401
        end
    end
end
