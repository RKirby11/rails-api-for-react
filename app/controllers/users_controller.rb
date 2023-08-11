class UsersController < ApplicationController

    skip_before_action :authenticate_user, only: [:create]
    before_action :find_user, only: [:show]

    def index
        @users = User.where("user_name like ?", "%#{search_param[:query]}%").where.not(id: @current_user).limit(6)
        @users = @users.map do |user| {
            'user_name': user.user_name,
            'avatar_url': user.presigned_avatar_url,
            'id': user.id,
            'relationship': @current_user.get_friendship_status(user.id)
        }
        end
        render json: { users: @users }, status: :ok
    end

    def show
        render json: { avatar_url: @user.presigned_avatar_url, bio: @user.bio, relationship: @current_user.get_friendship_status(@user.id) }, status: :ok
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
        def find_user
            @user = User.find_by_user_name(params[:user_name])
        end

        def create_user_params
            params.permit(:user_name, :email, :password, :password_confirmation)
        end

        def avatar_param
            params.permit(:avatar_url)
        end

        def bio_param
            params.permit(:bio)
        end

        def search_param
            params.permit(:query)
        end
end
