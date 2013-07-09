class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :name
      t.boolean :is_active

      t.timestamps
    end
  end
end
