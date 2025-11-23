# frozen_string_literal: true

class SecretSantaGamesController < ApplicationController
  before_action :require_login
  before_action :authorize_admin
  before_action :set_game, only: %i[show edit update destroy draw send_emails]

  helper SecretSanta::SecretSantaHelper

  def show
    render('secret_santa/games/show')
  end

  def new
    @game = SecretSanta::Game.new

    @available_players = SecretSanta::Player.all
    render('secret_santa/games/new')
  end

  def edit
    render('secret_santa/games/edit')
  end

  def create
    @game = SecretSanta::Game.new(game_params)
    if @game.save
      redirect_to(secret_santa_game_path(@game), notice: l(:notice_successful_create))
    else
      @available_players = SecretSanta::Player.all
      render('secret_santa/games/new')
    end
  end

  def update
    if @game.update(game_params)
      redirect_to(secret_santa_game_path(@game), notice: l(:notice_successful_update))
    else
      render('secret_santa/games/edit')
    end
  end

  def draw
    begin
      @game.draw!
      flash[:notice] = l(:label_draw_successful)
    rescue StandardError
      flash[:error] = l(:error_draw_failed)
    end
    redirect_to(secret_santa_game_path(@game))
  end

  def send_emails
    if @game.assignments.exists?
      @game.send_santa_emails
      flash[:notice] = l(:label_emails_has_ben_sent)
    else
      flash[:error] = l(:error_no_assignment_found)
    end
    redirect_to(secret_santa_game_path(@game))
  end

  def destroy
    @game.destroy
    redirect_to(secret_santa_path, notice: l(:notice_successful_delete))
  end

private

  def authorize_admin
    return if User.current.admin?

    redirect_to(secret_santa_path)
  end

  def set_game
    @game = SecretSanta::Game.find(params[:id])
  end

  def game_params
    params.require(:secret_santa_game).permit(:name, :message)
  end
end
