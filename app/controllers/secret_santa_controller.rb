# frozen_string_literal: true

class SecretSantaController < ApplicationController
  before_action :require_login

  helper SecretSanta::SecretSantaHelper

  def index
    @players = SecretSanta::Player.includes(:user).order(created_at: :desc)
    @games = SecretSanta::Game.order(created_at: :desc)
    @current_user_registered = SecretSanta::Player.exists?(id: User.current.id)
  end
end
