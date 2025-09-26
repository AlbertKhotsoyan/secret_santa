# frozen_string_literal: true

class CreateSecretSantaGames < ActiveRecord::Migration[5.2]
  def change
    create_table(:secret_santa_games) do |t|
      t.string(:name, null: false)
      t.integer(:group_id, null: false)
      t.text(:message_template)
      t.datetime(:drawn_at)
      t.timestamps
    end

    add_index(:secret_santa_games, :group_id)
  end
end
