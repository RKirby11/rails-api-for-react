class ApplicationController < ActionController::API
    
    # https://www.bacancytechnology.com/blog/build-rails-api-authentication-using-jwt
    include JwtToken
    
    before_action :authenticate_user

    def not_found
        render json: { error: 'not_found' }
    end

    private
        def authenticate_user
            header = request.headers['Authorization']
            header = header.split(' ').last if header
            begin
                @decoded = jwt_decode(header)
                @current_user = User.find(@decoded[:user_id])
            rescue ActiveRecord::RecordNotFound => e
                render json: { error: e.message }, status: :unauthorized
            rescue JWT::DecodeError => e
                render json: { error: e.message }, status: :unauthorized
            end
        end
end
