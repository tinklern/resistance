class AddStateToGames < ActiveRecord::Migration
  def change
    add_column :games, :state, :integer, :default => 0
  end
end
