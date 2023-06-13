class User < ApplicationRecord
    password_requirements = /\A
        (?=.{8,})          # Must contain 8 or more characters
        (?=.*[a-z])        # Must contain a lowercase character
        (?=.*[A-Z])        # Must contain an uppercase character
    /x
    has_secure_password

    has_many :submissions, dependent: :destroy
    validates :user_name, presence: true, uniqueness: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP , message: "must be a valid email address" }
    validates :password, presence: true, format: { with: password_requirements , message: "must contain 8 characters with atleast one uppercase and one lowercase" }
    validates :password_confirmation, presence: true

    before_create :generate_verification_token

    def generate_verification_token
        self.verification_token = SecureRandom.hex(10)
        self.verification_expiry = Time.new + 15.minutes
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

    def verify_email(token)
        if token == self.verification_token && self.verification_expiry > Time.new
            self.verified = true
            self.verification_token = nil
            self.verification_expiry = nil
            save(validate: false)
        end
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
end
