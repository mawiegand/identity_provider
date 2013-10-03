class InstallTracking::Device < ActiveRecord::Base
  
  has_many  :device_users,  :class_name => "InstallTracking::DeviceUser",    :foreign_key => :device_id,  :inverse_of => :device
  has_many  :installs,      :class_name => "InstallTracking::Install",       :foreign_key => :device_id,  :inverse_of => :device
  has_many  :identities,    :through    => :device_users,                                                 :inverse_of => :devices
  
  scope     :hardware,         lambda { |string| where(['hardware_string = ?',  string]) }
  scope     :operating_system, lambda { |string| where(['operating_system = ?', string]) }
  scope     :device_token,     lambda { |string| where(['device_token = ?',     string]) }

  scope     :vendor_token,     lambda { |string| where(['vendor_token = ?',     string]) }
  scope     :advertiser_token, lambda { |string| where(['advertiser_token = ?', string]) }
  scope     :hardware_token,   lambda { |string| where(['hardware_token = ?',   string]) }
  scope     :app_token,        lambda { |string| where(['app_token = ?',        string]) }

  scope     :no_device_token,  where('device_token IS NULL')

  scope     :descending, order('created_at DESC')
  
  
  def self.find_by_hardware_string_os_and_device_token(hw_string, os, token)
    devices = if token.blank?
      self.no_device_token.hardware(hw_string).operating_system(os)
    else
      self.device_token(token).hardware(hw_string).operating_system(os)      
    end
    
    devices.nil? || devices.empty? ? nil : devices.first
  end


  def self.create_or_update_with_identity(identity, hash)
    devices = self.find_by_identity_hardware_string_os_and_device_token(identity, hash['hardware_string'], hash['operating_system'], hash['device_token'])
    device = nil
    
    if devices.nil? || devices.empty?
      device = identity.devices.build({
        :hardware_string      => hash['hardware_string'],
        :operating_system     => hash['operating_system'],
        :device_token         => hash['device_token'],
        :vendor_token         => hash['vendor_token'],
        :advertiser_token     => hash['advertiser_token'],
        :hardware_token       => hash['hardware_token'],
      })
      device.save
    else
      device = devices.first
      
      unless device.nil?
        device.vendor_token     = hash['vendor_token']
        device.advertiser_token = hash['advertiser_token']
        device.hardware_token   = hash['hardware_token']
      
        device.save
      end
    end
    
    device
  end

  
    
  def self.create_or_update(hash)
    device = self.find_by_hardware_string_os_and_device_token(hash['hardware_string'], hash['operating_system'], hash['device_token'])
    
    if device.nil?
      device = InstallTracking::Device.new({
        :hardware_string      => hash['hardware_string'],
        :operating_system     => hash['operating_system'],
        :device_token         => hash['device_token'],
        :vendor_token         => hash['vendor_token'],
        :advertiser_token     => hash['advertiser_token'],
        :hardware_token       => hash['hardware_token'],
      })
      device.old_token        = hash['old_token']   unless hash['old_token'].blank? 
      device.save
    else
      device.vendor_token     = hash['vendor_token']
      device.advertiser_token = hash['advertiser_token']
      device.hardware_token   = hash['hardware_token']
      device.old_token        = hash['old_token']   unless hash['old_token'].blank? 
    
      device.save
    end
    
    device
  end
  
  
  def self.find_last_user_on_device_with_token(device_token)
    last_user = nil;
    
    InstallTracking::Device.device_token(device_token).descending.each do |device|
      last_user = last_user || device.last_user
    end
    
    last_user
  end


  def self.find_main_user_on_device_with_corresponding_device_information(device_information)
    device_information = device_information || {}
  
    device_token     = device_information[:device_token]
    old_token        = device_information[:old_token]
    vendor_token     = device_information[:vendor_token]
    advertiser_token = device_information[:advertiser_token]
    hardware_token   = device_information[:hardware_token]
    
    main_user = nil
    
    unless device_token.nil?
      InstallTracking::Device.device_token(device_token).descending.each do |device|
        duser = device.device_users.top_user.first
        if !duser.nil? && (main_user.nil? || main_user.auth_count < duser.auth_count)
          main_user = duser
        end
      end
    end
    
    unless vendor_token.nil? || vendor_token.blank?
      InstallTracking::Device.vendor_token(vendor_token).descending.each do |device|
        duser = device.device_users.top_user.first
        if !duser.nil? && (main_user.nil? || main_user.auth_count < duser.auth_count)
          main_user = duser
        end
      end
    end
    
    unless advertiser_token.nil? || advertiser_token.blank?
      InstallTracking::Device.advertiser_token(advertiser_token).descending.each do |device|
        duser = device.device_users.top_user.first
        if !duser.nil? && (main_user.nil? || main_user.auth_count < duser.auth_count)
          main_user = duser
        end
      end
    end
    
    # only use old methods in case we haven't found a suitable user, yet.
    if !main_user.nil? && main_user.auth_count > 10
      return main_user
    end
    
    unless hardware_token.nil?  || hardware_token.blank?
      InstallTracking::Device.hardware_token(hardware_token).descending.each do |device|
        duser = device.device_users.top_user.first
        if !duser.nil? && (main_user.nil? || main_user.auth_count < duser.auth_count)
          main_user = duser
        end
      end
    end
    
    unless old_token.nil? || old_token.blank?
      InstallTracking::Device.device_token(old_token).descending.each do |device|
        duser = device.device_users.top_user.first
        if !duser.nil? && (main_user.nil? || main_user.auth_count < duser.auth_count)
          main_user = duser
        end
      end
    end

    return main_user.nil? ? nil : main_user.identity;    
  end
  
  
  
  def self.find_last_user_on_device_with_corresponding_device_information(device_information)
    device_information = device_information || {}
  
    device_token     = device_information[:device_token]
    old_token        = device_information[:old_token]
    vendor_token     = device_information[:vendor_token]
    advertiser_token = device_information[:advertiser_token]
    hardware_token   = device_information[:hardware_token]
    
    last_user = nil
    
    unless device_token.nil?
      InstallTracking::Device.device_token(device_token).descending.each do |device|
        return device.last_user   unless device.last_user.nil?
      end
    end
    
    unless vendor_token.nil? || vendor_token.blank?
      InstallTracking::Device.vendor_token(vendor_token).descending.each do |device|
        return device.last_user   unless device.last_user.nil?
      end
    end
    
    unless advertiser_token.nil? || advertiser_token.blank?
      InstallTracking::Device.advertiser_token(advertiser_token).descending.each do |device|
        return device.last_user   unless device.last_user.nil?
      end
    end
    
    unless hardware_token.nil?  || hardware_token.blank?
      InstallTracking::Device.hardware_token(hardware_token).descending.each do |device|
        return device.last_user   unless device.last_user.nil?
      end
    end
    
    unless old_token.nil? || old_token.blank?
      InstallTracking::Device.device_token(old_token).descending.each do |device|
        return device.last_user   unless device.last_user.nil?
      end
    end

    return nil;
  end
  
  
  def first_user 
    device_user = device_users.first_use_ascending.limit(1).first
    device_user.nil? ? nil : device_user.identity
  end
  
  def last_user
    device_user = device_users.last_use_descending.limit(1).first
    device_user.nil? ? nil : device_user.identity
  end    
  
  # returns all tracking events that belong to this particular device
  def tracking_events
    InstallTracking::TrackingEvent.where(['device_token = ? OR old_token = ? OR device_token = ?', self.device_token || "NONE", self.device_token || "NONE", self.hardware_token || "NONE"]);
  end
  
end
