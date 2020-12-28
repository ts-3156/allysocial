Rails.application.routes.draw do
  root to: 'home#index'

  resource :dashboard, only: :show

  namespace :api, { format: 'json' } do
    resources :profiles, only: %i(show), param: :uid
    get 'followers_job_searches', to: 'followers_job_searches#show'
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'users/sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end
end
