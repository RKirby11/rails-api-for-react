class UserMailer < ApplicationMailer
    default from: 'demo@wordinspo.com'
    
    def email_verification(user)
        @user = user
        mail(to: @user.email, subject: "Email Verification")
    end

    def password_reset(user)
        @user = user
        mail(to: @user.email, subject: "Password Reset")
    end
end