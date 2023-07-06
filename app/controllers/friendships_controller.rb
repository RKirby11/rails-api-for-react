class FriendshipsController < ApplicationController

    def index
        @friends = @current_user.get_friends
        render json: @friends, status: :ok
    end

    # def friend_requests 
    #     @friend_requests = @current_user.get_friend_requests
    #     render json: @friend_requests, status: :ok
    # end

    def create
        if(create_params[:friend_name] === @current_user.user_name)
            render json: { error: 'You cannot send a friend request to yourself!' }, status: :bad_request
        end

        @friend = User.find_by(user_name: create_params[:friend_name])
        unless @friend
            render json: { error: 'User not found!' }, status: :not_found
            return
        end

        @friendship = Friendship.new(requester: @current_user, responder: @friend)
        if @friendship.save
            render json: { relationship: @current_user.get_friendship_status(@friend.id) }, status: :created
        else
            render json: { error: @friendship.errors.full_messages }, status: :service_unavailable
        end
    end

    def update
        @friendship = Friendship.find(update_params[:id])
        puts @friendship.inspect
        if @friendship.present? && @friendship.responder.id === @current_user.id
            friend_id = @friendship.requester.id
            puts friend_id
            if update_params[:update_type] === 'accept request'
                puts 'accepting request'
                @friendship.update_attribute(:accepted, true)
            elsif update_params[:update_type] === 'reject request'
                puts 'rejecting request'
                @friendship.destroy
            else 
                puts 'error'
                render json: { error: 'Invalid update type' }, status: :bad_request
                return
            end
            render json: { relationship: @current_user.get_friendship_status(friend_id) }, status: :ok
        else
            render json: { error: 'Not Authorised' }, status: :unauthorized
        end
    end

    def destroy
        @friendship = Friendship.find(delete_params[:id])
        if @friendship.present? && (@friendship.requester.id === @current_user.id || @friendship.responder.id === @current_user.id)
            friend_id = @friendship.requester.id === @current_user.id ? @friendship.responder.id : @friendship.requester.id
            @friendship.destroy
            render json: { relationship: @current_user.get_friendship_status(friend_id) }, status: :ok
        else
            render json: { error: 'Not Authorised' }, status: :unauthorized
        end
    end

    private
        def create_params
            params.permit(:friend_name)
        end

        def update_params
            params.permit(:id, :update_type)
        end

        def delete_params
            params.permit(:id)
        end
end
