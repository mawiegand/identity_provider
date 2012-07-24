class Resource::Game < ActiveRecord::Base

  has_many  :results,               :class_name => "Resource::Result",            :foreign_key => :game_id, :inverse_of => :game
  has_many  :events,                :class_name => "Resource::History",           :foreign_key => :game_id, :inverse_of => :game
  has_many  :character_properties,  :class_name => "Resource::CharacterProperty", :foreign_key => :game_id, :inverse_of => :game
  
  attr_accessible :identifier, :name, :link, :shared_secret,                     :as => :owner
  attr_accessible *accessible_attributes(:owner),                                :as => :creator # fields accesible during creation
  attr_accessible *accessible_attributes(:creator), :scopes,                     :as => :staff
  attr_accessible *accessible_attributes(:staff),                                :as => :admin
    
  attr_readable :name, :link, :id,                                               :as => :default 
  attr_readable *readable_attributes(:default), :created_at,                     :as => :user
  attr_readable *readable_attributes(:user), :identifier, :scopes, :updated_at, :shared_secret, :as => :owner
  attr_readable *readable_attributes(:user),                                     :as => :staff
  attr_readable *readable_attributes(:staff),                                    :as => :admin
  
end
