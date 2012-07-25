class Resource::History < ActiveRecord::Base
  
  belongs_to  :identity,  :class_name => "Identity",       :foreign_key => :identity_id, :inverse_of => :events
  belongs_to  :game,      :class_name => "Resource::Game", :foreign_key => :game_id,     :inverse_of => :events
  
  serialize   :data
  serialize   :localized_description
  
end
