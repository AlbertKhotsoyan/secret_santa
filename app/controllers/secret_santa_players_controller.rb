# frozen_string_literal: true

class SecretSantaPlayersController < ApplicationController
  before_action :require_login
  before_action :set_player, only: %i[edit update destroy]

  helper SecretSanta::SecretSantaHelper

  def new
    @player = SecretSanta::Player.new
    render('secret_santa/players/new')
  end

  def edit
    if params[:id].to_i == User.current.id
      render('secret_santa/players/edit')
    else
      redirect_to(secret_santa_path)
    end
  end

  def create
    @player = SecretSanta::Player.new(player_params.merge(id: User.current.id))
    if @player.save
      redirect_to(secret_santa_path, notice: l(:notice_successful_create))
    else
      render('secret_santa/players/new')
    end
  end

  def update
    unless @player.id == User.current.id || User.current.admin?
      render_403
      return
    end

    if @player.update(player_params)
      redirect_to(secret_santa_path, notice: l(:notice_successful_update))
    else
      render('secret_santa/players/edit')
    end
  end

  def destroy
    if @player.id == User.current.id || User.current.admin?
      @player.destroy
      redirect_to(secret_santa_path, notice: l(:notice_successful_delete))
    else
      render_403
    end
  end

private

  def set_player
    @player = SecretSanta::Player.find(params[:id])
  end

  def player_params
    params.require(:secret_santa_player).permit(:want_to_get, :dont_want_to_get)
  end
end
