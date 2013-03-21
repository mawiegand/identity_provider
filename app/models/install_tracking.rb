module InstallTracking
  
  def self.table_name_prefix
    'install_tracking_'
  end
  
  # returns the updated install_user matching the specified
  # identity, client and information received from the client.
  # creates and updates devices, installs and releases on the fly.
  # Order of processing:
  #
  # find release      or create it

  # find device       or create it
  # find device user  or create it
  # update last use
  
  # find install      or create it
  # find install user or create it
  # update last use
  #
  # Example: 
  #   InstallTracking.handle_install_usage(Identity.find(6), Client.find('4'), { "hardware_string" => "iPhone4,1", "operating_system" => "iOS 3.0", "version" => "1.2", "device_token" => "myDToken", "app_token" => "myAToken" })

  
  def self.handle_install_usage(identity, client, device_info)
    
    now = DateTime.now
  
    # unique identifiers for device
    device_hardware = device_info['hardware_string']  || "unknown"
    device_os       = device_info['operating_system'] || "unknown"
    device_token    = device_info['device_token'].blank? ? nil : device_info['device_token']
    
    # unique identifiers for release (together with client)
    client_version  = device_info['version']          || "unknown"
    
    # unique identifiers for install (together with device and release)
    app_token       = device_info['app_token']        || "missing"
    
    
    # ########################################################################
    #
    #   check release
    #
    # ########################################################################
        
    release = client.releases.version(client_version).first
    if release.nil?
      release = client.releases.create(:version => client_version)
    end
      
    if release.nil?   # fail due to inability to create a new release
      logger.error    "ERROR: failed to create new release of client #{client} version #{version}."
      return nil
    end

      
    # ########################################################################
    #
    #   check device
    #
    # ########################################################################
        
    device = InstallTracking::Device.find_by_hardware_string_os_and_device_token(device_hardware, device_os, device_token)
    if device.nil?
      device = InstallTracking::Device.create({
        :hardware_string  => device_hardware,
        :operating_system => device_os,
        :device_token     => device_token
      })  
    end
    
    if device.nil?
      logger.error    "ERROR: failed to create new device #{ device_hardware } os #{ device_os } token #{ device_token }."
      return nil
    end
    

    # ########################################################################
    #
    #   check install
    #
    # ########################################################################
    
    install = release.installs.token(app_token).find_by_device_id(device.id)
    if install.nil?
      install = release.installs.create({
        :device_id => device.id,
        :app_token => app_token 
      })
    end
    
    if install.nil?
      logger.error    "ERROR: failed to create new install #{ app_token } on device #{ device.id } for release #{ release.id }."
      return nil
    end
    
    
    # ########################################################################
    #
    #   check install user
    #
    # ########################################################################    
    
    install_user = install.install_users.find_by_identity_id(identity.id)
    if install_user.nil?
      install_user = install.install_users.create({
        :identity_id  => identity.id,
        :first_use_at => now,
      })
    end
    
    if install_user.nil?
      logger.error    "ERROR: failed to create new install user for install #{ install.id } and identity #{ identity.id }."
      return nil
    end  
    
    install_user.last_use_at   = now
    install_user.sign_in_count = install_user.sign_in_count + 1
    
    install_user.save 
    
  end
  
  
end
