class InstallTracking::Install < ActiveRecord::Base

  belongs_to :release,        :class_name => "ClientRelease",                :foreign_key => :release_id,  :inverse_of => :installs
  belongs_to :device,         :class_name => "InstallTracking::Device",      :foreign_key => :device_id,   :inverse_of => :installs

  has_many   :install_users,  :class_name => "InstallTracking::InstallUser", :foreign_key => :install_id,  :inverse_of => :install
  has_many   :identities,     :through    => :install_users,                                               :inverse_of => :installs

  scope      :token,     lambda { |token| where(['app_token = ?', token]) }

  scope      :descending, order('created_at DESC')


  # find device       or create it
  # find device user  or create it
  # update last use
  
  # find install      or create it
  #  find release     or create it
  # find install user or create it
  # update last use  
end
