class GamesController < ApplicationController
  
  def index
    
  end
  
  def create
    game = Game.create!( :name => params[:game_name] )
    session[:auth] = SecureRandom.uuid
    player = Player.create!( :game => game, :name => params[:player_name] || "Player 1", :auth_hash => session[:auth] )
    redirect_to :action => "lobby", :id => game.id
  end
  
  def join
    game = Game.find_by_name( params[:game_name] )
    raise "No game found by the name of '#{params[:game_name]}'" if game.nil?
    raise "This game is already in session" if game.is_active?
    session[:auth] = SecureRandom.uuid
    player = Player.create!( :game => game, :name => params[:player_name] || "Player #{game.players.count + 1}", :auth_hash => session[:auth] )
    
    js_res = "
      $( '.lobby_table' ).append( '<tr><td>#{player.name}</td><td><div id=\"player_#{player.id}_ready\" class=\"label label-important\">Not Ready</div></td></tr>' );
    "
  
    PrivatePub.publish_to "/lobby/#{game.id}", js_res
    redirect_to :action => "lobby", :id => game.id
  end

  def lobby
    raise "You don't belong here!" unless params[:id].present? && session[:auth].present?
    @game = Game.find( params[:id] )
    @player = Player.find_by_auth_hash( session[:auth] )
  end
  
  def game
    @game = Game.find( params[:id] )
  end
end
