class InstallTracking::Device < ActiveRecord::Base
  
  has_many  :device_users,  :class_name => "InstallTracking::DeviceUser", :foreign_key => :device_id,  :inverse_of => :device
  has_many  :installs,      :class_name => "InstallTracking::Install",    :foreign_key => :install_id, :inverse_of => :device
  has_many  :identities,    :through    => :device_users,                                              :inverse_of => :devices

  scope     :hardware,         lambda { |string| where(['hardware_string = ?',  string]) }
  scope     :operating_system, lambda { |string| where(['operating_system = ?', string]) }
  scope     :device_token,     lambda { |string| where(['device_token = ?',     string]) }
  scope     :no_device_token,  where('device_token IS NULL')


  def self.find_by_hardware_string_os_and_device_token(hw_string, os, token)
    devices = if token.blank?
      self.no_device_token.hardware(hw_string).operating_system(os)
    else
      self.device_token(token).hardware(hw_string).operating_system(os)      
    end
    
    devices.nil? || devices.empty? ? nil : devices.first
  end
  
    
  def self.create_or_update(identity, hash)
    devices = self.find_by_identity_hardware_string_os_and_device_token(identity, hash['hardware_string'], hash['operating_system'], hash['device_token'])
    device = nil
    
    if devices.nil? || devices.empty?
      device = identity.devices.build({
        :hardware_string  => hash['hardware_string'],
        :operating_system => hash['operating_system'],
        :device_token     => hash['device_token'],
      })
      device.save
    else
      device = devices.first
    end
    
    device
  end
  
end
