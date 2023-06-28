class FriendshipsController < ApplicationController

    def index
        @friends = @current_user.get_friends
        render json: @friends, status: :ok
    end

    def friend_requests 
        @friend_requests = @current_user.get_friend_requests
        render json: @friend_requests, status: :ok
    end

    def create
        @responder = User.find_by_user_name(params[:responder_name])
        @friendship = Friendship.new(requester: @current_user.id, responder: @responder.id, accepted: false)
        if @friendship.save
            render json: { message: 'Friend request sent!'}, status: :created
        else
            render json: { error: @friendship.errors.full_messages }, status: :service_unavailable
        end
    end

    def accept
        @friendship = Friendship.find(friendship_update_params[:friendship_id])
        if @friendship.present? && @friendship.responder_id === @current_user.id
            @friendship.accepted = true
            @friendship.save
            render json: { message: 'Friend request accepted!'}, status: :ok
        else
            render json: { error: 'Not Authorised' }, status: :unauthorized
        end
    end

    def destroy
        @friendship = Friendship.find(friendship_update_params[:friendship_id])
        if @friendship.present? && (@friendship.requester === @current_user.id || @friendship.responder === @current_user.id)
            @friendship.destroy
            render json: { message: 'Friendship deleted!'}, status: :ok
        else
            render json: { error: 'Not Authorised' }, status: :unauthorized
        end
    end

    private
        def friendship_update_params
            params.permit(:friendship_id)
        end
end
