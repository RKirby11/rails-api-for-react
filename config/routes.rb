Rails.application.routes.draw do
  post "/auth/login", to: "authentication#login"

  get "/dailyword", to: "daily_word#index"

  resources :users, param: :user_name do
    resources :submissions
  end
  
  get '/*a', to: 'application#not_found'
  post '/*a', to: 'application#not_found'
end
