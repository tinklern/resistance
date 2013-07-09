class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.integer :game_id
      t.integer :loyalty

      t.timestamps
    end
  end
end
