class InstallTracking::Device < ActiveRecord::Base
  
  has_many  :device_users,  :class_name => "InstallTracking::DeviceUser", :foreign_key => :device_id, :inverse_of => :device
  has_many  :identities,    :through    => :device_users,                                             :inverse_of => :devices
  
  scope     :hardware,         lambda { |string| where(['hardware_string = ?',  string]) }
  scope     :operating_system, lambda { |string| where(['operating_system = ?', string]) }
  scope     :device_token,     lambda { |string| where(['device_token = ?',     string]) }
  scope     :no_device_token,  where('device_token IS NULL')
    
  def self.create_or_update(identity, hash)
    devices = if (hash['device_token'].blank?)
      identity.devices.no_device_token.hardware(hash['hardware_string']).operating_system(hash['operating_system'])
    else
      identity.devices.device_token(hash['device_token']).hardware(hash['hardware_string']).operating_system(hash['operating_system'])      
    end
    
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
