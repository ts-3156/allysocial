Rails.application.routes.draw do
  root to: 'home#index'

  get 'login', to: 'login#index'
  get 'dashboard', to: 'dashboard#index'
  get 'waiting', to: 'waiting#index'

  namespace :api, { format: 'json' } do
    resources :profiles, only: %i(show), param: :uid
    get 'searches', to: 'searches#show'
    resources :label_options, only: %i(index)
    get 'twitter_users', to: 'twitter_users#show'

    resources :webhooks, only: %i(create)
    resources :checkout_sessions, only: %i(create)
    resources :subscriptions, only: %i(destroy)
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'users/sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  require 'sidekiq/web'
  if Rails.env.production?
    authenticate :user, lambda { |u| u.id == 1 } do
      mount Sidekiq::Web => '/sidekiq'
    end
  elsif Rails.env.development?
    mount Sidekiq::Web => '/sidekiq'
  end
end
