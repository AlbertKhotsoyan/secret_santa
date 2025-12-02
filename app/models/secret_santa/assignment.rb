# frozen_string_literal: true

module SecretSanta
  class Assignment < ActiveRecord::Base
    self.table_name = 'secret_santa_assignments_new'

    belongs_to :game, class_name: 'SecretSanta::Game', foreign_key: :secret_santa_game_id
    belongs_to :giver, class_name: 'SecretSanta::Player', foreign_key: :giver_id
    belongs_to :receiver, class_name: 'SecretSanta::Player', foreign_key: :receiver_id

    def self.count_for_player(player_id)
      where(giver_id: player_id).count
    end
  end
end
