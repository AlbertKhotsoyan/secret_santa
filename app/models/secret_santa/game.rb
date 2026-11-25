# frozen_string_literal: true

module SecretSanta
  class Game < ActiveRecord::Base
    class NotEnoughPlayersError < StandardError; end

    MIN_PLAYERS_COUNT = 2

    self.table_name = 'secret_santa_games'

    has_many :assignments, class_name: 'SecretSanta::Assignment', foreign_key: :secret_santa_game_id, dependent: :destroy

    validates :name, presence: true

    def draw!
      players = SecretSanta::Player.order(created_at: :desc).to_a
      raise NotEnoughPlayersError if players.size < MIN_PLAYERS_COUNT

      shuffled = players.shuffle

      game_assignments = shuffled.each_with_index.map do |giver, idx|
        receiver = shuffled[(idx + 1) % shuffled.size]
        {giver_id: giver.id, receiver_id: receiver.id}
      end

      transaction do
        assignments.delete_all
        game_assignments.shuffle.each { |attrs| assignments.create!(attrs) }
      end
    end

    def valid_assignments_cycle?
      rows = assignments.pluck(:giver_id, :receiver_id)
      return false if rows.size < MIN_PLAYERS_COUNT
      return false if rows.any? { |giver_id, receiver_id| giver_id == receiver_id }

      giver_ids = rows.map(&:first)
      receiver_ids = rows.map(&:last)
      giver_ids.uniq.size == rows.size && giver_ids.sort == receiver_ids.sort
    end

    def send_santa_emails
      failed_messages = []

      assignments.includes(giver: :user, receiver: :user).find_each do |assignment|
        giver_user = assignment.giver&.user
        next unless giver_user

        SecretSantaMailer.santa_email(giver_user, assignment).deliver_later
      rescue StandardError => e
        Rails.logger&.error("SecretSanta email delivery failed for user #{assignment.giver_id}: #{e.message}")
        failed_messages << e.message
      end

      failed_messages
    end
  end
end
