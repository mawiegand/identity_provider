class InstallTracking::PushNotificationToken < ActiveRecord::Base

  belongs_to  :identity, :class_name => 'Identity', :primary_key => :identifier, :foreign_key => :identifier, :inverse_of => :push_tokens

end
