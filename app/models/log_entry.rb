class LogEntry < ActiveRecord::Base
  belongs_to :identity
  
  default_scope :order => 'log_entries.created_at DESC'
end
