class UsersController < ApplicationController

    skip_before_action :authenticate_user, only: [:create]

    def index
        //TODO
    end

    def show_bio
        render json: { bio: @current_user.bio }, status: :ok
    end

    def create
        @user = User.create(create_user_params)
        if @user.save
            UserMailer.email_verification(@user).deliver_now
            render json: @user, status: :created
        else
            render json: { error: @user.errors.full_messages }, status: :service_unavailable
        end
    end

    def update_avatar
        if @current_user.update_avatar_url(avatar_param[:avatar_url])
            render json: { avatar_url:  @current_user.presigned_avatar_url }, status: :ok
        else
            render json: { error: @current_user.errors.full_messages }, status: :service_unavailable
        end
    end

    def update_bio
        if @current_user.update_bio(bio_param[:bio])
            render json: { bio: @current_user.bio}, status: :ok
        else
            render json: { error: @current_user.errors.full_messages }, status: :service_unavailable
        end
    end

    def destroy
        unless @current_user.destroy
            render json: { error: @user.errors.full_messages }, status: :service_unavailable
        end
    end

    private
        def create_user_params
            params.permit(:user_name, :email, :password, :password_confirmation)
        end

        def avatar_param
            params.permit(:avatar_url)
        end

        def bio_param
            params.permit(:bio)
        end
end
