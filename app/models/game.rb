class Game < ActiveRecord::Base
  has_many :players, :dependent => :destroy
  has_many :rounds, :dependent => :destroy
  belongs_to :current_round, :class_name => "Round", :foreign_key => :current_round_id
  
  attr_accessor :leader
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  SPY_NUMBERS = {
    "2" => 1,
    "3" => 2,
    "4" => 2,
    
    "5" => 2,
    "6" => 2,
    "7" => 3,
    "8" => 3,
    "9" => 3,
    "10" => 4
  }
  
  MISSION_COUNT = {
    "2" => [2, 2, 2, 2, 2],
    "3" => [2, 2, 2, 2, 2],
    "4" => [2, 2, 2, -3, 3],
    
    "5" => [2, 3, 2, 3, 3],
    "6" => [2, 3, 4, 3, 4],
    "7" => [2, 3, 3, -4, 4],
    "8" => [3, 4, 4, -5, 5],
    "9" => [3, 4, 4, -5, 5],
    "10" => [3, 4, 4, -5, 5]
  }  
end
