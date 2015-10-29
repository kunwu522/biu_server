class Api::V1::SuggestionsController < ApplicationController
    
    api :POST, "/suggestions"
    param :suggestion, Hash, :desc => "suggestion info" do
        param :advice, String, :desc => "advice"
        param :email, String, :desc => "email"
        param :user_id, String, :desc => "user id"
    end
    def create
        suggestion = Suggestion.new(suggestion_params)
        if suggestion.save
            render json: "", status: 200
        else
            render json: "", status: 500
        end
    end
    
    private
    def suggestion_params
        params.require(:suggestion).permit(:advice, :email, :user_id)
    end
end
