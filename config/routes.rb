Rails.application.routes.draw do
  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :project, only: [:index, :show]
  resources :submissions, only: [:create]

  root to: "project#index"
end
