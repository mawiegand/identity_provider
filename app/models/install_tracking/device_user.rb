class InstallTracking::DeviceUser < ActiveRecord::Base

  belongs_to  :identity,  :class_name => "Identity",                :foreign_key => :identity_id,  :inverse_of => :device_users
  belongs_to  :device,    :class_name => "InstallTracking::Device", :foreign_key => :device_id,    :inverse_of => :device_users
  
  scope :first_use_ascending, order('first_use_at ASC')
  
end
