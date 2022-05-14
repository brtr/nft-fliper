require "sidekiq/pro/web"
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  root "nft_flip_records#index"

  mount Sidekiq::Web => "/sidekiq"
  mount API::Root => '/'

  resources :nfts, except: :destroy do
    get :purchase_rank, on: :collection
    get :holding_rank, on: :collection
    get :sync_data, on: :member
    get :bch_list, on: :member
  end

  resources :holding_rank_snap_shots, only: [:index, :show]
  resources :nft_snap_shots, only: [:index, :show]

  resources :nft_flip_records, only: :index do
    collection do
      get :fliper_detail
      get :collection_detail
      get :check_new_records
      get :get_new_records
    end
  end

  post 'login', to: "users#login", as: :login
  post 'logout', to: "users#logout", as: :logout
  get '/users/:id/nfts', to: "users#nfts", as: :user_nfts
  get '/extensions', to: "home#extensions", as: :extensions
end
