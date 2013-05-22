class InstallTracking::TrackingEvent < ActiveRecord::Base

  scope :descending, order('created_at DESC')

end
