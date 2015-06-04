module Api::V1::SessionsHelper
    # Log in the given user.
    def log_in(user)
        session[:user_id] = user.id
    end
    
    # Log out the current user
    def log_out
        forget(current_user)
        session.delete(:user_id)
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
        user = User.find_by(id: user_id)
        if user && user.authenticated?(cookie[:remember_token])
            log_in user
            @current_user = user
        end
    end
    
    # Return true if the user is logged in
    def logged_in?
        !@current_user.nil?
    end
end
