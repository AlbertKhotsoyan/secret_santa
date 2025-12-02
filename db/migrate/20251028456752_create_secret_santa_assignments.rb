# frozen_string_literal: true

class CreateSecretSantaAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table(:secret_santa_assignments_new) do |t|
      t.references(:secret_santa_game, null: false, foreign_key: {to_table: :secret_santa_games})
      t.integer(:giver_id, null: false)
      t.integer(:receiver_id, null: false)

      t.timestamps
    end

    add_index(:secret_santa_assignments_new, [:secret_santa_game_id, :giver_id], unique: true, name: 'index_ss_assignments_new_on_game_and_giver')
    add_foreign_key(:secret_santa_assignments_new, :secret_santa_players_new, column: :giver_id, primary_key: :id, on_delete: :cascade)
    add_foreign_key(:secret_santa_assignments_new, :secret_santa_players_new, column: :receiver_id, primary_key: :id, on_delete: :cascade)
  end
end
