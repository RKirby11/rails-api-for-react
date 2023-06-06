Rails.application.routes.draw do
  post "/auth/login", to: "authentication#login"

  resources :users, param: :user_name do
    resources :submissions
  end
  
  get '/*a', to: 'application#not_found'
end
