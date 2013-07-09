class Player < ActiveRecord::Base
  belongs_to :game
  
  validates_presence_of :name, :auth_hash
  validates_uniqueness_of :auth_hash
end
