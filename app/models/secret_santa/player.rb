# frozen_string_literal: true

module SecretSanta
  class Player < ActiveRecord::Base
    self.table_name = 'secret_santa_players'
    self.primary_key = 'id'

    belongs_to :user, class_name: 'User', foreign_key: :id

    validates :id, presence: true, uniqueness: true
    validates :want_to_get, length: {maximum: 2000}
    validates :dont_want_to_get, length: {maximum: 2000}

    def name
      user.try(:name)
    end

    def email
      user.try(:mail)
    end
  end
end
