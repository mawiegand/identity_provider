class Game::GameInstance < ActiveRecord::Base
  
  belongs_to :game,          :class_name => "Resource::Game",  :foreign_key => :game_id,          :inverse_of => :instances
  has_many   :servers,       :class_name => "Game::Server",    :foreign_key => :game_instance_id, :inverse_of => :game_instance
  
  scope      :visible_to_non_insiders, where(hidden_for_non_insiders: false)
  scope      :visible,                 where(hidden: false)
  scope      :available,               where(['available_since < ? AND ended_at > ?', DateTime.now, DateTime.now])
  scope      :running,                 where(['started_at < ? AND ended_at > ?', DateTime.now, DateTime.now])
  scope      :non_insider,             where(insider_only: false)
  
  attr_accessor :current_identity
  
  def self.most_recent_running_public_game
    return Game::GameInstance.visible_to_non_insiders.visible.running.non_insider.order('started_at DESC').limit(1).first
  end
  
  def random_selected_servers
    types = self.server_types.split(",").map { |v| v.strip }
    
    selected_servers = {}
    
    types.each do |type| 
       selected_servers[type] = self.servers.where(type_string: type).first # random select one!
    end
    
    selected_servers
  end
  
  def has_player_joined?
    !current_identity.nil? && current_identity.grants.where("scopes LIKE '%#{self.scope}%'").count > 0
  end
  
  def started?
    !self.started_at.nil? && self.started_at < DateTime.now
  end
  
  def ended?
    self.ended_at.nil? || self.ended_at < DateTime.now 
  end
  
  def default_game?
    self == Game::GameInstance.most_recent_running_public_game
  end
  
end
