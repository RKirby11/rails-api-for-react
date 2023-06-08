class AuthenticationController < ApplicationController

    skip_before_action :authenticate_user

    def login
        @user = User.find_by_email(params[:email])
        if @user&.authenticate(params[:password])
            token = jwt_encode({user_id: @user.id})
            time = Date.tomorrow.midnight

            todays_word = DailyWord.where(date: Date.today.beginning_of_day).first
            if ! todays_word.present?
                todays_word = DailyWord.create(word: Faker::Verb.base, date: Date.today.beginning_of_day)
            end

            render json: { 
                jwt: {
                    token: token,
                    expiry: time.strftime("%m-%d-%Y %H:%M")
                },
                username: @user.user_name,
                todays_word: todays_word.word
            }, status: :ok
        else
            render json: { 
                error: "Authentication failed - please check your credentials and try again." 
                }, status: :unauthorized
        end
    end
end
