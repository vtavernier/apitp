Rails.application.routes.draw do
  devise_for :users, skip: :registrations
  devise_scope :user do
    resource :registration,
             only: [:edit, :update],
             path: 'users',
             controller: 'devise/registrations',
             as: :user_registration
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :project, only: [:index, :show]
  resources :submissions, only: [:create]

  root to: "project#index"
end
