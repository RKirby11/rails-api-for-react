class AuthenticationController < ApplicationController

    skip_before_action :authenticate_user

    def login
        @user = User.find_by_email(params[:email])

        if params[:email_verification_code] && ! @user.verified
            @user.verify_email(params[:email_verification_code])
        end

        if @user&.authenticate(params[:password]) && @user.verified
            token = jwt_encode({user_id: @user.id})
            time = Date.today.end_of_day

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
                todays_word: todays_word.word,
                avatar_url: @user.presigned_avatar_url
            }, status: :ok

        else
            if @user && ! @user.verified && params[:email_verification_code]
                error = "The verification link used has expired."
            elsif @user && ! @user.verified
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
        @user = User.find_by_email(params[:email])
        if @user
            @user.generate_verification_token
            @user.save(validate: false)
            UserMailer.email_verification(@user).deliver_now
            render json: { message: "Verification email sent." }, status: :ok
        else
            render json: { error: "No account with that email address exists." }, status: :not_found
        end
    end

    def send_password_reset_email
        @user = User.find_by_email(params[:email])
        if @user.present?
            @user.generate_password_reset_token
            UserMailer.password_reset(@user).deliver_now
            render json: { message: "Password reset link sent." }, status: :ok
        else
            render json: { error: "No account with that email address exists." }, status: :not_found
        end
    end

    def reset_password
        @user = User.find_by_password_reset_token(params[:password_reset_token])
        if @user.present?
            begin 
                @user.reset_password(params[:password_reset_token], params[:password], params[:password_confirmation]) 
                render json: { message: "Password reset." }, status: :ok
            rescue => e
                render json: { error: e.message }, status: :bad_request
            end
        else
            render json: { error: "Invalid password reset token." }, status: :bad_request
        end
    end
end
