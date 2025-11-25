# frozen_string_literal: true

module SecretSanta
  class Assignment < ActiveRecord::Base
    self.table_name = 'secret_santa_assignments'

    belongs_to :game, class_name: 'SecretSanta::Game', foreign_key: :secret_santa_game_id
    belongs_to :giver, class_name: 'SecretSanta::Player', foreign_key: :giver_id
    belongs_to :receiver, class_name: 'SecretSanta::Player', foreign_key: :receiver_id
  end
end
