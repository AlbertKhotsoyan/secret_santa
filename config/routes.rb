# frozen_string_literal: true

RedmineApp::Application.routes.draw do
  get 'secret_santa', to: 'secret_santa#index', as: :secret_santa

  resources :secret_santa_players, controller: 'secret_santa_players', except: %i[index show]
  resources :secret_santa_games, controller: 'secret_santa_games', except: %i[index] do
    member do
      post :draw
      post :send_emails
    end
  end
end
