class AddAuthHashToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :auth_hash, :string
  end
end
