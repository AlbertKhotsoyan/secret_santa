# frozen_string_literal: true

class SecretSantaController < ApplicationController
  before_action :require_login
  before_action :find_game, only: [:show, :draw, :send_emails, :destroy]
  before_action :authorize_secret_santa

  def index
    @games = SecretSanta::Game.order(created_at: :desc)
  end

  def show
    @assignments = @game.assignments.includes(:giver, :receiver)
  end

  def new
    @game = SecretSanta::Game.new
    # list all groups (only groups with users and emails)
    @groups = Group.all.select { |g| game_group_users(g).any? }
  end

  def create
    @game = SecretSanta::Game.new(game_params)
    if @game.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to(action: :show, id: @game.id)
    else
      @groups = Group.all.select { |g| game_group_users(g).any? }
      render(action: :new)
    end
  end

  # POST /secret_santa/:id/draw
  def draw
    users = participants_for_game(@game)
    if users.size < 2
      flash[:error] = I18n.t('secret_santa.errors.not_enough_participants')
      redirect_to(action: :show, id: @game.id) and return
    end

    SecretSanta::Assignment.transaction do
      @game.assignments.destroy_all
      assignments = SecretSanta::Allocator.draw(users)
      assignments.each do |giver, receiver|
        @game.assignments.create!(giver_id: giver.id, receiver_id: receiver.id)
      end
      @game.update!(drawn_at: Time.current)
    end

    flash[:notice] = I18n.t('secret_santa.messages.draw_success')
    redirect_to(action: :show, id: @game.id)
  rescue StandardError => e
    flash[:error] = "Draw failed: #{e.message}"
    redirect_to(action: :show, id: @game.id)
  end

  # POST /secret_santa/:id/send_emails
  def send_emails
    if @game.assignments.empty?
      flash[:error] = I18n.t('secret_santa.errors.no_assignments')
      redirect_to(action: :show, id: @game.id) and return
    end

    enqueued = 0
    @game.assignments.includes(:giver, :receiver).find_each do |assignment|
      next unless assignment.giver && assignment.receiver
      next if assignment.giver.mail.blank?

      # enqueue job
      SecretSanta::AssignmentEmailJob.perform_later(@game.id, assignment.id)
      enqueued += 1
    end

    flash[:notice] = I18n.t('secret_santa.messages.emails_sent', count: enqueued)
    redirect_to(action: :show, id: @game.id)
  end

  def destroy
    @game.destroy
    flash[:notice] = I18n.t('secret_santa.messages.deleted')
    redirect_to(action: :index)
  end

private

  def authorize_secret_santa
    authorize_for(:secret_santa, :manage_secret_santa)
  end

  def game_params
    params.require(:secret_santa_game).permit(:name, :group_id, :message_template)
  end

  def find_game
    @game = SecretSanta::Game.find_by(id: params[:id])
    render_404 if @game.nil?
  end

  def participants_for_game(game)
    group = Group.find_by(id: game.group_id)
    return [] unless group

    # use the helper method to filter users with emails and active
    game_group_users(group)
  end

  def game_group_users(group)
    # Group.users returns User or Principal objects; convert to User and filter
    group.users.select { |u| u.is_a?(User) && u.active? && u.mail.present? }
  end
end
