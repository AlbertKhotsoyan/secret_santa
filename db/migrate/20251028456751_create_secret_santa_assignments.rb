# frozen_string_literal: true

class CreateSecretSantaAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table(:secret_santa_assignments) do |t|
      t.references(:secret_santa_game, null: false, foreign_key: {to_table: :secret_santa_games})
      t.integer(:giver_id, null: false)
      t.integer(:receiver_id, null: false)

      t.timestamps
    end

    add_index(:secret_santa_assignments, [:secret_santa_game_id, :giver_id], unique: true, name: 'index_ss_assignments_on_game_and_giver')
    add_foreign_key(:secret_santa_assignments, :secret_santa_players, column: :giver_id, primary_key: :id)
    add_foreign_key(:secret_santa_assignments, :secret_santa_players, column: :receiver_id, primary_key: :id)
  end
end
