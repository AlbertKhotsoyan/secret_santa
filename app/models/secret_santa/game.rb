# frozen_string_literal: true

module SecretSanta
  class Game < ActiveRecord::Base
    self.table_name = 'secret_santa_games'

    has_many :assignments, class_name: 'SecretSanta::Assignment', foreign_key: :secret_santa_game_id, dependent: :destroy

    validates :name, presence: true

    def draw!
      players = SecretSanta::Player.order(created_at: :desc)
      raise StandardError, l(:error_not_enough_players) if players.size < 2

      shuffled = players.shuffle

      game_assignments = shuffled.each_with_index.map do |giver, idx|
        receiver = shuffled[(idx + 1) % shuffled.size]
        {giver_id: giver.id, receiver_id: receiver.id}
      end

      assignments.delete_all
      game_assignments.shuffle.each { |attrs| assignments.create!(attrs) }
    end

    def send_santa_emails
      assignments.each do |assignment|
        SecretSantaMailer.santa_email(assignment.giver.user, assignment).deliver_now
      end
    end
  end
end
