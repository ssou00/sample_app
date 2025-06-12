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
  resources :users do
  # GET	/users	index	users_path	すべてのユーザーを一覧するページ
  # GET	/users/1	show	user_path(user)	特定のユーザーを表示するページ
  # GET	/users/new	new	new_user_path	ユーザーを新規作成するページ（ユーザー登録）
  # POST	/users	create	users_path	ユーザーを作成するアクション
  # GET	/users/1/edit	edit	edit_user_path(user)	id=1のユーザーを編集するページ
  # PATCH	/users/1	update	user_path(user)	ユーザーを更新するアクション
  # DELETE	/users/1	destroy	user_path(user)	ユーザーを削除するアクション
    member do # memberを使うとユーザーidを含むURLを扱うようになる
      get :following, :followers
    end
  # GET	/users/1/following	following	following_user_path(1)
  # GET	/users/1/followers	followers	followers_user_path(1)
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
  
  get '/microposts', to: 'static_pages#home'

end
