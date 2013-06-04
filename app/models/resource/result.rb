class Resource::Result < ActiveRecord::Base

  belongs_to  :identity,  :class_name => "Identity",       :foreign_key => :identity_id, :inverse_of => :results
  belongs_to  :game,      :class_name => "Resource::Game", :foreign_key => :game_id,     :inverse_of => :results 
  
  scope :game,      lambda { |gid| where(:game_id => gid.to_i) }
  scope :round,     lambda { |round| where(:round_number => round.to_i) }
  scope :top20,     order('individual_rank ASC').limit(20)
  
end
