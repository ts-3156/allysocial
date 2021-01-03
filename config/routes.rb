Rails.application.routes.draw do
  root to: 'home#index'

  get 'dashboard', to: 'dashboard#index'
  get 'waiting', to: 'waiting#index'

  namespace :api, { format: 'json' } do
    resources :profiles, only: %i(show), param: :uid
    get 'searches', to: 'searches#show'
    resources :job_options, only: %i(index)
    resources :location_options, only: %i(index)
    resources :url_options, only: %i(index)
    resources :keyword_options, only: %i(index)
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'users/sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end
end
