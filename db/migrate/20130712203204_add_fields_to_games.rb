class AddFieldsToGames < ActiveRecord::Migration
  def change
    add_column :games, :neg_score, :int, :default => 0
    add_column :games, :pos_score, :int, :default => 0
    add_column :games, :current_round_id, :int
  end
end
