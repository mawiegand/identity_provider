class Resource::CharacterProperty < ActiveRecord::Base

  belongs_to  :identity,  :class_name => "Identity",       :foreign_key => :identity_id, :inverse_of => :character_properties
  belongs_to  :game,      :class_name => "Resource::Game", :foreign_key => :game_id,     :inverse_of => :character_properties

  serialize :data

end
