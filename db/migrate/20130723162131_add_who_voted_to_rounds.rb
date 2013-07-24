class AddWhoVotedToRounds < ActiveRecord::Migration
  def change
    add_column :rounds, :who_voted, :text
  end
end
