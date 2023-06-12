Rails.application.routes.draw do
  post "/auth/login", to: "authentication#login"
  get "/auth/verification_email", to: "authentication#send_verification_email"
  get "/auth/validate_email/:verification_token", to: "authentication#validate_email", as: :validate_email
  get "/dailyword", to: "daily_word#index"

  resources :users, param: :user_name do
    resources :submissions
  end
  
  get '/*a', to: 'application#not_found'
  post '/*a', to: 'application#not_found'
end
