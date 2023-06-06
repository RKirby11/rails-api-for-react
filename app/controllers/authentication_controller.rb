class AuthenticationController < ApplicationController

    skip_before_action :authenticate_user

    def login
        @user = User.find_by_email(params[:email])
        if @user&.authenticate(params[:password])
            token = jwt_encode({user_id: @user.id})
            time = Time.now + 24.hours.to_i
            render json: { 
                token: token,
                expiry: time.strftime("%m-%d-%Y %H:%M"),
                username: @user.user_name
                }, status: :ok
        else
            render json: { 
                error: "Authentication failed - please check your credentials and try again." 
                }, status: :unauthorized
        end
    end
end
