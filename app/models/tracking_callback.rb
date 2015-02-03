# Handles incoming tracking calls and device attributions.
#
# PLEASE NOTE: later, we should attribute device installs, NOT
# devices or identities, as the identity provider may support
# several apps, not only one.
class TrackingCallback < ActiveRecord::Base
  
  validates :device_id, :refid, presence: true
  
  after_save :attribute_device_and_user

  scope :device_id,   lambda { |device_id| where(["device_id = ?", device_id]) }
  scope :latest,      lambda { |n| order('created_at DESC').limit(n) }
  scope :descending,  order('created_at DESC') 

  def self.find_latest_by_device_id(device_id)
    TrackingCallback.device_id(device_id).latest(1).first
  end
  
  def connected?
    !connected_at.nil?
  end
  
  # actually attributes the incomming tracking call with devices and users, but only if
  # the user / device was created during the LAST 30 DAYS
  # the user / device is not already attributed to another origin.
  def attribute_device_and_user
    
    # do not attribute organic traffic (adjust sends a callback with "Organic__" in this case.)
    return true    if self.refid.downcase.start_with?("organic")
    
    # attribute matching devices to referrer (could be more than one, in case vendor_token did change due to reinstallation etc.)
    InstallTracking::Device.advertiser_token(device_id).created_since(30.days.ago.utc).each do |device|
      if device.ref_id.nil?
        device.ref_id = self.refid
        device.sub_id = self.subid
        device.save
        
        self.connected_at = DateTime.now
        self.save
      end
    end
    
    # attribute the last user on device, IFF he was not already attributed!
    user = InstallTracking::Device.find_last_user_on_device_with_advertiser_token(device_id)
    
    if !user.nil? && user.ref_id.nil? && user.created_at >= 30.days.ago.utc
      user.ref_id = refid
      user.sub_id = subid
      user.save
      
      if self.connected_at.nil?
        self.connected_at = DateTime.now
        self.save
      end
    end
    
    true
  end
  
end
