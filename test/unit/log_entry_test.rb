require 'test_helper'

class LogEntryTest < ActiveSupport::TestCase

  test "check data is valid" do
    entry = LogEntry.new(:role => 'none', 
                         :affected_table => 'identities', 
                         :description => 'test entry')
    assert !entry.nil?
    assert entry.valid?
    assert_equal entry.role, 'none'
    assert_equal entry.description, 'test entry'
  end
  
  test "existing log entries can not be modified" do
    entry = LogEntry.new(:role => 'none')
    entry.save
    entry = LogEntry.find(entry.id)
    assert_equal entry.role, 'none'
    entry.role = 'admin'
    entry.save
    entry = LogEntry.find(entry.id)
    assert_equal entry.role, 'none' 
  end
  
end
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

