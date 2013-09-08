class Game::Server < ActiveRecord::Base

  belongs_to :game_instance,   :class_name => "Game::GamequiInstance",   :foreign_key => :game_instance_id,   :inverse_of => :servers

end
