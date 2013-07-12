class Round < ActiveRecord::Base
  belongs_to :game
  belongs_to :leader, :class_name => "Player", :foreign_key => :leader_id
  serialize :team_ids, Array
  
  validates_presence_of :leader_id, :game_id
  
  def team_members
    Player.where( :id => team_ids )
  end
  
  def num_members
    team_ids.count
  end
end
