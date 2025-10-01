# frozen_string_literal: true

class CreateSecretSantaAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table(:secret_santa_assignments) do |t|
      t.integer(:game_id, null: false)
      t.integer(:giver_id, null: false)
      t.integer(:receiver_id, null: false)
      t.timestamps
    end

    add_index(:secret_santa_assignments, :game_id)
    add_index(:secret_santa_assignments, [:game_id, :giver_id], unique: true)
  end
end
