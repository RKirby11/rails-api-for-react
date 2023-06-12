class User < ApplicationRecord
    password_requirements = /\A
        (?=.{8,})          # Must contain 8 or more characters
        (?=.*[a-z])        # Must contain a lowercase character
        (?=.*[A-Z])        # Must contain an uppercase character
    /x
    
    has_many :submissions, dependent: :destroy
    has_secure_password
    validates :user_name, presence: true, uniqueness: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP , message: "must be a valid email address" }
    validates :password, presence: true, format: { with: password_requirements , message: "must contain 8 characters with atleast one uppercase and one lowercase" }
    validates :password_confirmation, presence: true

    before_create :generate_verification_token

    def generate_verification_token
        self.verification_token = SecureRandom.hex(10)
    end

    def verify_email
        self.verified = true
        save(validate: false)
    end
    
end
