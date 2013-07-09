class Game < ActiveRecord::Base
  has_many :players, :dependent => :destroy
  # has_many :votes
  
  validates_presence_of :name
  validates_uniqueness_of :name
end
