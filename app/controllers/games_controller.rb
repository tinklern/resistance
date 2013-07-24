class GamesController < ApplicationController
  
  def index
    session[:game_ended] = nil
  end
  
  def create
    game = Game.create!( :name => params[:game_name] )
    session[:auth] = SecureRandom.uuid
    player = Player.create!( :game => game, :name => params[:player_name].present? ? params[:player_name] : "Player1", :auth_hash => session[:auth] )
    redirect_to :action => "lobby", :id => game.id
  end
  
  def join
    game = Game.find_by_name( params[:game_name] )
    raise "No game found by the name of '#{params[:game_name]}'" if game.nil?
    
    if game.is_active? 
      if current_player.try( :game_id ) != game.id
        raise "This game is already in session" 
      else
        redirect_to :action => "game", :id => game.id
        return
      end
    end
    session[:auth] = SecureRandom.uuid
    player = Player.create!( :game => game, :name => params[:player_name].present? ? params[:player_name] : "Player#{game.players.count + 1}", :auth_hash => session[:auth] )
    
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
    begin
      @game = Game.find( params[:id] )
    rescue
      redirect_to :action => 'index'
      return
    end
    
    @players = @game.players.order("id")
    
    if !@game.is_active? && !@game.is_over?
      redirect_to :action => "lobby", :id => @game.id
      return
    end
    
    raise "You aren't in this game!" unless @players.pluck( :auth_hash ).include? session[:auth]
    
    if @game.is_over? && @game.is_active?
      @game.update_attributes!( :state => Game::States::ENDED, :is_active => false )
    end
    
    case @game.state
    when Game::States::LEADER
      if @game.current_round_id.blank?
        @game.current_round = Round.create( :leader => @players.first, :game => @game )  
        @game.save!
      elsif ( !@game.current_round.passed_team_vote? && @game.current_round.has_votes? ) || @game.current_round.has_mission_votes?
        new_round = Round.create( :leader => next_leader( @game, @game.current_round.leader ), :game => @game )  
        @game.update_attributes!( :current_round_id => new_round.id )
      end
    when Game::States::TEAM_VOTE
      @team_players = @players.select{ |p| @game.current_round.team_ids.include? p.id }
    when Game::States::MISSION_VOTE
      @team_players = @players.select{ |p| @game.current_round.team_ids.include? p.id }
    when Game::States::ENDED
      if session[:game_ended].present?
        redirect_to :action => 'index'
        return
      end
      session[:game_ended] = "true"
    end
    
    @round = @game.current_round
  end
  
  def submit_team
    game = Game.find( params[:id] )
    game.update_attributes!( :state => Game::States::TEAM_VOTE )
    
    game.current_round.update_attributes!( :who_voted => nil )
    
    PrivatePub.publish_to "/game/#{game.id}", "location.reload();"
    
    render :text => "done"
  end
  
  def submit_team_vote
    game = Game.find( params[:id] )
    
    raise "You can't do this" unless game.state == Game::States::TEAM_VOTE || game.current_round_id.blank?
    
    round = game.current_round
    if params[:vote] == "yes"
      round.who_voted << current_player.id
      round.update_attributes!( :yes_votes => round.yes_votes.to_i + 1 )
    elsif params[:vote] == "no"
      round.who_voted << current_player.id
      round.update_attributes!( :no_votes => round.no_votes.to_i + 1 )
    else
      raise "You're doing it wrong"
    end
    
    PrivatePub.publish_to "/game/#{game.id}", "$( '.total_votes' ).html( '#{round.total_team_votes}' )"
    PrivatePub.publish_to "/game/player/#{current_player.id}", "$( '.vote_options' ).hide();"
    
    if round.total_team_votes >= game.players.count # all votes in
      if round.passed_team_vote?
        round.update_attributes!( :who_voted => nil )
        game.update_attributes!( :state => Game::States::MISSION_VOTE )
        PrivatePub.publish_to "/game/#{game.id}", "alert( 'YES' );"
      else
        game.update_attributes!( :state => Game::States::LEADER )
        PrivatePub.publish_to "/game/#{game.id}", "alert( 'NO' );"
      end
      PrivatePub.publish_to "/game/#{game.id}", "location.reload();"
    end

    render :text => "done"
  end
  
  def submit_mission_vote
    game = Game.find( params[:id] )
    
    raise "You can't do this" unless game.state == Game::States::MISSION_VOTE || game.current_round_id.blank?
    
    round = game.current_round
    if params[:vote] == "pass"
      round.who_voted << current_player.id
      round.update_attributes!( :pass_votes => round.pass_votes.to_i + 1 )
    elsif params[:vote] == "fail"
      round.who_voted << current_player.id
      round.update_attributes!( :fail_votes => round.fail_votes.to_i + 1 )
    else
      raise "You're doing it wrong"
    end
    
    PrivatePub.publish_to "/game/#{game.id}", "$( '.total_votes' ).html( '#{round.total_mission_votes}' )"
    PrivatePub.publish_to "/game/player/#{current_player.id}", "$( '.vote_options' ).hide();"
    
    if round.total_mission_votes >= round.team_ids.count # all votes in
      if round.passed_mission_vote?
        game.update_attributes!( :pos_score => game.pos_score + 1, :state => Game::States::LEADER )
        PrivatePub.publish_to "/game/#{game.id}", "alert( 'PASSED' );"
      else
        game.update_attributes!( :neg_score => game.neg_score + 1, :state => Game::States::LEADER )
        PrivatePub.publish_to "/game/#{game.id}", "alert( 'FAILED' );"
      end
        
      PrivatePub.publish_to "/game/#{game.id}", "location.reload();"
    end

    render :text => "done"
  end
  
  

  private
  
  
  def next_leader( game, leader )
    players = game.players.order( "id" ).all
    
    idx = players.find_index( leader ) + 1
    if idx == players.count
      players.first
    else
      players[idx]
    end
  end

end
