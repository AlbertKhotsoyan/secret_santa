# frozen_string_literal: true

class CreateSecretSantaPlayers < ActiveRecord::Migration[5.2]
  def change
    create_table(:secret_santa_players, id: false) do |t|
      # rubocop:disable Rails/DangerousColumnNames
      t.primary_key(:id)
      # rubocop:enable Rails/DangerousColumnNames
      t.text(:want_to_get)
      t.text(:dont_want_to_get)

      t.timestamps
    end

    add_foreign_key(:secret_santa_players, :users, column: :id, on_delete: :cascade)
  end
end
