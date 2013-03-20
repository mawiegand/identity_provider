class InstallTracking::Device < ActiveRecord::Base
  
  has_many  :device_users,          :class_name => "InstallTracking::DeviceUser", :foreign_key => :device_id, :inverse_of => :device
  has_many  :identities,            :through    => :device_users,                                             :inverse_of => :devices
  
end
