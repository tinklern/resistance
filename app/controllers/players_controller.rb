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
    
    game = player.game
    players = game.players
    unless players.size <= 1 || players.pluck( :is_ready ).include?( false )
      
      # setup loyalties
      game.update_attributes!( :is_active => true );

      spies = players.sample( Game::SPY_NUMBERS[players.size.to_s] )

      spies.each do |spy|
        spy.update_attributes!( :loyalty => 1 )
      end
    
      players.each do |player|
        player.update_attributes!( :loyalty => 0 ) unless spies.include? player
      end
      
      PrivatePub.publish_to "/lobby/#{game.id}", "window.location = '#{game_path( :id => game.id)}';"
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
  
  def toggle_team
    player = Player.find( params[:id] )
    game = player.game
    
    raise "You're doing it wrong" if game.nil? || game.current_round_id.nil?
    
    round = game.current_round
    channel = "/game/#{game.id}"
    
    if round.team_ids.include? player.id # remove
      round.team_ids.delete( player.id )
      js_res = "$( '#player_#{player.id}_in_round' ).html( '' );"
    else
      if round.team_num < game.team_num # add
        round.team_ids.insert( 0, player.id )
        js_res = "$( '#player_#{player.id}_in_round' ).html( '&#9996;' );"
      else # full, can't add
        js_res = "alert('You already have the full team size.');"
        channel = "/game/player/#{current_player.id}"
      end
    end
    
    if round.team_num == game.team_num
      js_res += "$( '.submit_team_link' ).removeClass( 'hidden' );"
    else
      js_res += "$( '.submit_team_link' ).addClass( 'hidden' );"
    end  
  
    round.save!
    
    PrivatePub.publish_to channel, js_res
    
    render :text => "done"
  end
end
