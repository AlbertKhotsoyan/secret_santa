# frozen_string_literal: true

class CreateSecretSantaPlayers < ActiveRecord::Migration[5.2]
  def change
    create_table(:secret_santa_players_new, id: false) do |t|
      t.primary_key(:id, :integer)

      t.text(:want_to_get)
      t.text(:dont_want_to_get)

      t.timestamps
    end

    add_foreign_key(:secret_santa_players_new, :users, column: :id, primary_key: :id, on_delete: :cascade)
  end
end
