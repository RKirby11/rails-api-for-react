class User < ApplicationRecord
    password_requirements = /\A
        (?=.{8,})          # Must contain 8 or more characters
        (?=.*[a-z])        # Must contain a lowercase character
        (?=.*[A-Z])        # Must contain an uppercase character
    /x
    has_secure_password

    has_many :submissions, dependent: :destroy
    has_many :friendships, dependent: :destroy

    validates :user_name, presence: true, uniqueness: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP , message: "must be a valid email address" }
    validates :password, presence: true, format: { with: password_requirements , message: "must contain 8 characters with atleast one uppercase and one lowercase" }
    validates :password_confirmation, presence: true

    before_create :generate_verification_token

    def generate_verification_token
        self.verification_token = SecureRandom.hex(10)
        self.verification_expiry = Time.new + 15.minutes
    end

    def verify_email(token)
        if token == self.verification_token && self.verification_expiry > Time.new
            self.verified = true
            self.verification_token = nil
            self.verification_expiry = nil
            save(validate: false)
        end
    end

    def generate_password_reset_token
        password_reset_token = SecureRandom.hex(10)
        while User.find_by_password_reset_token(password_reset_token)
            password_reset_token = SecureRandom.hex(10)
        end
        self.password_reset_token = password_reset_token
        self.password_reset_expiry = Time.new + 15.minutes
        self.save(validate: false)
    end

    def reset_password(token, password, password_confirmation)
        if self.password_reset_token.present? && token == self.password_reset_token && self.password_reset_expiry > Time.new
            self.password = password
            self.password_confirmation = password_confirmation
            self.password_reset_token = nil
            self.password_reset_expiry = nil
            begin
                save!
            rescue => e
                raise e.message
            end
        else 
            raise "Invalid password reset token."
        end
    end

    def update_avatar_url(avatar_url)
        self.avatar_url = avatar_url
        save(validate: false)
    end

    def presigned_avatar_url
        if self.avatar_url.nil?
            return nil
        else
            obj = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET_NAME']).object(self.avatar_url)
            return obj.presigned_url(:get, expires_in: 86400)
        end
    end

    def update_bio(bio)
        self.bio = bio
        save(validate: false)
    end

    def get_friends()
        friendships = Friendship.where(requester: self.id, accepted: true).or(Friendship.where(responder: self.id, accepted: true))
        friendships = friendships.map do |friendship|
            if friendship.requester.id === self.id
                {
                    'username': friendship.responder.user_name,
                    'avatar': friendship.responder.presigned_avatar_url
                }
            else
                {
                    'username': friendship.requester.user_name,
                    'avatar': friendship.requester.presigned_avatar_url
                }
            end
        end
        return friendships
    end

    def get_friend_requests()
        friend_requests = Friendship.where(responder: self.id, accepted: false)
        friend_requests = friend_requests.map do |friend_request|
            {
                'id': friend_request.id,
                'username': friend_request.requester.user_name,
                'avatar': friend_request.requester.presigned_avatar_url
            }
        end
        return friend_requests
    end

    def get_friendship_status(user_id)
        if(user_id == self.id) 
            return { 'status': 'self', 'id': nil}
        else
            friendship = Friendship.where(requester: self.id, responder: user_id).or(Friendship.where(requester: user_id, responder: self.id)).first
            if friendship.nil?
                return { 'status': 'not friends', 'id': nil}
            elsif friendship.accepted
                return { 'status': 'friends', 'id': friendship.id}
            elsif friendship.requester.id === self.id
                return { 'status': 'request sent', 'id': friendship.id}
            else
                return { 'status': 'request received', 'id': friendship.id}
            end
        end
    end
end
