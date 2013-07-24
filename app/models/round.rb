class Round < ActiveRecord::Base
  belongs_to :game
  belongs_to :leader, :class_name => "Player", :foreign_key => :leader_id
  serialize :team_ids, Array
  serialize :who_voted, Array
  
  validates_presence_of :leader_id, :game_id
  
  def team_members
    Player.where( :id => team_ids )
  end
  
  def team_num
    team_ids.count
  end
  
  def total_team_votes
    yes_votes.to_i + no_votes.to_i
  end
  
  def total_mission_votes
    pass_votes.to_i + fail_votes.to_i
  end
  
  def passed_team_vote?
    return yes_votes.to_i > no_votes.to_i
  end
  
  def passed_mission_vote?
    if game.double_fail_round?
      return fail_votes.to_i < 2
    else
      return fail_votes.to_i < 1
    end
  end
  
  def has_votes?
    return yes_votes.present? || no_votes.present? || pass_votes.present? || fail_votes.present?
  end
  
  def has_mission_votes?
    return pass_votes.present? || fail_votes.present?
  end
end
