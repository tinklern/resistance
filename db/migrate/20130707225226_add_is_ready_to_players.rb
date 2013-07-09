class AddIsReadyToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :is_ready, :boolean, :default => false
  end
end
