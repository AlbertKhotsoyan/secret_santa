# frozen_string_literal: true

module SecretSanta
  class Game < ActiveRecord::Base
    self.table_name = 'secret_santa_games'

    validates :name, presence: true
    validates :group_id, presence: true

    has_many :assignments, class_name: 'SecretSanta::Assignment', dependent: :destroy, foreign_key: :game_id
  end
end
