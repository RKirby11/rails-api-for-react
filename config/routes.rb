Rails.application.routes.draw do
  post "/auth/login", to: "authentication#login"
  post "/auth/resend_verification", to: "authentication#send_verification_email"
  post "/auth/request_password_reset", to: "authentication#send_password_reset_email"
  post "/auth/reset_password", to: "authentication#reset_password"
  
  get "/dailyword", to: "daily_word#index"

  resources :users, param: :user_name, except: [:update] do
    member do
      patch :update_avatar
      patch :update_bio
    end
    resources :submissions
  end

  resources :friendships, except: [:show]
  
  get '/*a', to: 'application#not_found'
  post '/*a', to: 'application#not_found'
end
