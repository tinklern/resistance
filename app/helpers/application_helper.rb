module ApplicationHelper
  
  def current_player
    Player.find_by_auth_hash( session[:auth] )
  end
  
end
