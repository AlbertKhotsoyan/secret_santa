# frozen_string_literal: true

class SecretSantaController < ApplicationController
  before_action :require_login

  helper SecretSanta::SecretSantaHelper

  def index
    @players = SecretSanta::Player.order(created_at: :desc)
    @games = SecretSanta::Game.order(created_at: :desc)
  end
end
