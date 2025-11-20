# frozen_string_literal: true

class CreateSecretSantaGames < ActiveRecord::Migration[5.2]
  def change
    create_table(:secret_santa_games) do |t|
      t.string(:name, null: false)
      t.text(:message)

      t.timestamps
    end
  end
end
