Rails.application.routes.draw do
  root 'top#index'

  # 認証用ルート
  get 'signup', to: 'auth#signup'
  post 'signup', to: 'auth#create_signup'
  get 'login', to: 'auth#login'
  post 'login', to: 'auth#create_login'
  delete 'logout', to: 'auth#destroy'

  # パスワードリセットリクエスト
  get 'password/reset', to: 'passwords#new', as: :new_password_reset
  post 'password/reset', to: 'passwords#create'

  # パスワード更新画面
  get 'password/edit', to: 'passwords#edit', as: :edit_password
  patch 'password/update', to: 'passwords#update'

  resource :mypage, only: [:show, :edit, :update]

  get 'families/guide', to: 'families#guide'

  scope module: :families do
    resources :families do
      resources :members, only: [:index, :new, :create, :destroy]
      resources :children, only: [:index, :new, :create, :edit, :update, :destroy]
    end
  end

  resources :diaries do
    resources :reactions, only: [:create, :destroy]
    member do
      get :refresh_emoji
    end
    collection do
      get 'date_index'
      get 'filter'
    end
  end

  # APIエンドポイントの定義
  namespace :api do
    namespace :v1 do
      resource :user, only: [], path: 'users' do
        post :register_on_rails, on: :collection
      end

      resources :items, only: [:index]
    end
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
