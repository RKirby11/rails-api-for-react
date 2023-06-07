class UsersController < ApplicationController

    skip_before_action :authenticate_user, only: [:create]

    def index
        @users = User.all
        render json: @users, status: 200
    end

    def show
        render json: @current_user, status: 200
    end

    def create
        @user = User.create(user_params)
        if @user.save
            render json: @user, status: 201
        else
            render json: { error: @user.errors.full_messages }, status: 503
        end
    end

    def update
        unless @current_user.update(user_params)
            render json: { error: @user.errors.full_messages }, status: 503
        end
    end

    def destroy
        unless @current_user.destroy
            render json: { error: @user.errors.full_messages }, status: 503
        end
    end

    private
        def user_params
            params.permit(:user_name, :email, :password, :name)
        end
end
