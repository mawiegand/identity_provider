class ClientRelease < ActiveRecord::Base
  
  belongs_to :client,   :class_name => "Client",                   :foreign_key => :client_id,  :inverse_of => :releases

  has_many   :installs, :class_name => "InstallTracking::Install", :foreign_key => :release_id, :inverse_of => :release

  scope      :version,   lambda { |string| where(['version = ?', string]) } 
  
end
