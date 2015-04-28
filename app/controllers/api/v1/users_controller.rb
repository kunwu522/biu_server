class Api::V1::UsersController < Api::V1::BaseController
  
  private
  
  def user_params
    params.require(:user).permit(:username, :password)
  end
  
  def query_params
    params.permit(:user_id, :username, :password)
  end
  
end
