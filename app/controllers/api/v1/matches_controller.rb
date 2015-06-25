class Api::V1::MatchesController < ApplicationController
    
    def update
        user = User.find(params[:id])
        if user
            user.update_attributes(location_params)
        else
            error = {"error_message" => I18n.t('user_not_exist')}
            render json: error, statue: 404;
        end
    end
    
    def match
        user = User.find(params[:id])
        if user
            matched_users = user.find_by_sql("SELECT *, (6378.1 * acos(cos(radians(40.055220)) 
                                                                * cos(radians(latitude)) 
                                                                * cos(radians(longitude) - radians(116.291080)) 
                                                                + sin(radians(40.055220)) 
                                                                * sin(radians(latitude)))) AS distance 
                                              FROM users 
                                              WHERE users.id <> 4 
                                              HAVING distance < 1 
                                              ORDER BY distance")
        else
            render json: "", statue: 200;
        end
    end
    
    private
    def location_params
        params.require(:location).permit(:latitude, :longitude)
    end
end
