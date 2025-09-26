# frozen_string_literal: true

module SecretSanta
  class Assignment < ActiveRecord::Base
    self.table_name = 'secret_santa_assignments'

    belongs_to :game, class_name: 'SecretSanta::Game', foreign_key: :game_id
    belongs_to :giver, class_name: 'User', foreign_key: :giver_id, optional: true
    belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true

    validates :giver_id, presence: true
    validates :receiver_id, presence: true
  end
end
