class Api::V1::SessionsController < Api::V1::BaseController
    def create
        user = User.find_by(email: params[:session][:email].downcase)
        if user && user.authenticate(params[:session][:password])
            Rails.logger.debug { "#{user.email} log in..." }
            log_in user
            remember user
            user_response = {
                'id' => user.id,
                'username' => user.username,
                'password' => user.password_digest,
                'email' => user.email
            }
            render json: user_response
        else
            error = {
                'errorCode' => '1001',
                'errorMessage' => 'Invalid email or password.'
            }
            render json: error, status: :unprocessable_entity
        end
    end
    
    def destroy
        log_out
    end
end
