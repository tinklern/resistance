class PlayersController < ApplicationController
  def ready
    player = Player.find_by_auth_hash( session[:auth] )
    player.update_attributes!( :is_ready => !player.is_ready )
    
    js_res = "
      var player_rdy = $( player_#{player.id}_ready );
      player_rdy.html( '#{player.is_ready? ? "Ready" : "Not Ready" }' );
      
      if( player_rdy.is( 'a' ) ) player_rdy.swapClass( 'btn-success', 'btn-danger' );
      else if( player_rdy.is( '.label' ) ) player_rdy.swapClass( 'label-success', 'label-important' );
    "
    PrivatePub.publish_to "/lobby/#{player.game_id}", js_res
    
    
    unless player.game.players.pluck( :is_ready ).include?( false )
      js_res = "
        alert( 'all players ready game will start in 5 seconds' );
      "
      PrivatePub.publish_to "/lobby/#{player.game_id}", js_res
    end
    
    redirect_to :back
  end
  
  def change_name
    player = Player.find_by_auth_hash( session[:auth] )
    player.update_attributes!( :name => params[:player_name] )
    
    js_res = "
      $( '#player_#{player.id}_name .player_name' ).removeClass( 'hidden' ).html( '#{player.name}' );
      $( '#player_#{player.id}_name .player_name_field' ).addClass( 'hidden' ).find( 'input' ).val('').keyup();
      
    "
    
    PrivatePub.publish_to "/lobby/#{player.game_id}", js_res
    
    redirect_to :back
  end
end
