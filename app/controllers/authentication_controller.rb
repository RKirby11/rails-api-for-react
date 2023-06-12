class AuthenticationController < ApplicationController

    skip_before_action :authenticate_user , only: [:login, :validate_email]

    def login
        @user = User.find_by_email(params[:email])

        if params[:email_verification_code] && @user&.verification_token == params[:email_verification_code]
            @user.verify_email
        end

        if @user&.authenticate(params[:password]) && @user.verified
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
            if @user && ! @user.verified
                error = "Please check your emails for a verification link in order to sign in."
            else
                error = "Authentication failed - please check your credentials and try again."
            end
            render json: { 
                error: error
            }, status: :unauthorized
        end
    end

    def send_verification_email
        UserMailer.email_verification(@current_user).deliver_now
        render json: { message: "Verification email sent." }, status: 200
    end
end
