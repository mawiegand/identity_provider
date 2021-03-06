class InstallTracking::DeviceUser < ActiveRecord::Base

  belongs_to  :identity,  :class_name => "Identity",                :foreign_key => :identity_id,  :inverse_of => :device_users
  belongs_to  :device,    :class_name => "InstallTracking::Device", :foreign_key => :device_id,    :inverse_of => :device_users
  
  scope :first_use_ascending, order('first_use_at ASC')
  scope :last_use_descending, order('last_use_at DESC')
  
  scope :most_auths_first,    order('auth_count DESC')
  scope :top_user,            order('auth_count DESC').limit(1)
  
end
