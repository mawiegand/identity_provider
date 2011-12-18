# Log entries store information about changes made to the 
# database. For each change made by a controller, that 
# controller should create a LogEntry explaining that
# particular change. Besides a human readable description,
# a log entry has information about the identity that
# made the change, the identity's role (none, user, staff,
# or admin) and the table and table-row affected by the
# change. 
#
# Attributes are read only so the log can not be manipulated
# through the rails application.
#
# Log entries can be easily browsed and filtered by accessing
# the LogEntriesController at /log_entries . 
#
# == Schema Information
#
# Table name: log_entries
#
#  id             :integer         not null, primary key
#  identity_id    :integer
#  role           :string(255)
#  affected_table :string(255)
#  affected_id    :integer
#  event_type     :string(255)
#  description    :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#
class LogEntry < ActiveRecord::Base
  belongs_to :identity      # entries are connected to the current_user

  attr_accessible :identity_id, :role, :affected_table, :affected_id, :event_type, :description 
  attr_readonly :identity_id, :role, :affected_table, :affected_id, :event_type, :description
  
  default_scope :order => 'log_entries.created_at DESC'   # most recent entry comes first
end


