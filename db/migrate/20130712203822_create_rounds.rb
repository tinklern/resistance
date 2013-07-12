class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.integer :leader_id
      t.text :team_ids
      t.integer :yes_votes
      t.integer :no_votes
      t.integer :pass_votes
      t.integer :fail_votes
      t.integer :game_id

      t.timestamps
    end
  end
end
