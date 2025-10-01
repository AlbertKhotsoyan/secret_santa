# frozen_string_literal: true

RedmineApp::Application.routes.draw do
  get 'secret_santa', to: 'secret_santa#index'
  get 'secret_santa/new', to: 'secret_santa#new', as: 'new_secret_santa'
  post 'secret_santa', to: 'secret_santa#create', as: 'create_secret_santa'

  get 'secret_santa/:id', to: 'secret_santa#show', as: 'secret_santa_id'
  delete 'secret_santa/:id', to: 'secret_santa#destroy', as: 'destroy_secret_santa'

  post  'secret_santa/:id/draw',        to: 'secret_santa#draw', as: 'draw_secret_santa'
  post  'secret_santa/:id/send_emails', to: 'secret_santa#send_emails', as: 'send_secret_santa_emails'
end
