class Game::GameInstance < ActiveRecord::Base
  
  belongs_to :game,          :class_name => "Resource::Game",  :foreign_key => :game_id,          :inverse_of => :instances
  has_many   :servers,       :class_name => "Game::Server",    :foreign_key => :game_instance_id, :inverse_of => :game_instance
  
  scope      :visible_to_non_insiders, where(hidden_for_non_insiders: false)
  scope      :visible,                 where(hidden: false)
  scope      :available,               where(['available_since < ? AND ended_at > ?', DateTime.now, DateTime.now])
  
  
  def random_selected_servers
    types = self.server_types.split(",").map { |v| v.strip }
    
    selected_servers = {}
    
    types.each do |type| 
       selected_servers[type] = self.servers.where(type_string: type).first # random select one!
    end
    
    selected_servers
  end
  
end
