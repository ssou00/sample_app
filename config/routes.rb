Rails.application.routes.draw do
  root "static_pages#home"
  
# 名前付きのルーティングを定義することができる
  get "/help", to: "static_pages#help"
# help_path -> '/'
# help_url  -> 'https://www.example.com/help'
# 上の2つも使用できる
  get "/about", to: "static_pages#about"
  get "/contact", to: "static_pages#contact"
  get "/signup", to: "users#new"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # /users/1といったユーザー情報を表示するURLの追加
  # さらにshow, new, edit, updateなどのRESTfulなアクションの追加
  resources :users
end
