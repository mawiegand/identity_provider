class InstallTracking::InstallUser < ActiveRecord::Base
  
  belongs_to :install,  :class_name => "InstallTracking::Install", :foreign_key => :install_id,   :inverse_of => :install_users
  belongs_to :identity, :class_name => "Identity",                 :foreign_key => :identity_id,  :inverse_of => :install_users

  after_create :create_corresponding_device_user_if_necessary  
  after_save   :update_corresponding_device_user_if_necessary  
    

  def find_corresponding_device_user
    self.install.device.device_users.find_by_identity_id(self.identity_id)
  end



  protected
  
    def create_corresponding_device_user_if_necessary  
      
      device_user = self.find_corresponding_device_user
      if device_user.nil?
        self.install.device.device_users.create({
          :identity_id  => self.identity_id,
          :first_use_at => self.first_use_at,
        })
      end
      
      true
    end
    
    
    def update_corresponding_device_user_if_necessary  
      if self.last_use_at_changed?
        device_user = self.find_corresponding_device_user
        if device_user.nil?
          logger.error "corresponding device user for install_user #{self.id} is missing!"
        else
          device_user.last_use_at = self.last_use_at
          device_user.save
        end
      end
      
      true
    end
    
    
  
end
