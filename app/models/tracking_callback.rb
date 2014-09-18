class TrackingCallback < ActiveRecord::Base
  
  
  def connected?
    !connected_at.nil?
  end
  
  
  
end
