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
    return render_403 unless @player.id == User.current.id || User.current.admin?

    if @player.update(player_params)
      redirect_to(secret_santa_path, notice: l(:notice_successful_update))
    else
      render('secret_santa/players/edit')
    end
  end

  def destroy
    return render_403 unless @player.id == User.current.id || User.current.admin?

    assignments_count = SecretSanta::Assignment.count_for_player(@player.id)
    if assignments_count.positive?
      flash[:error] = l(:error_participated_to_assignment, assignments_count: assignments_count)
      redirect_to(secret_santa_path)
      return
    end

    if @player.destroy
      flash[:notice] = l(:notice_successful_delete)
    else
      flash[:error] = "#{l(:error_player_deletion_failed)}: #{@player.errors.full_messages.join(', ')}"
    end

    redirect_to(secret_santa_path)
  end

private

  def set_player
    @player = SecretSanta::Player.find(params[:id])
  end

  def player_params
    params.require(:secret_santa_player).permit(:want_to_get, :dont_want_to_get)
  end
end
