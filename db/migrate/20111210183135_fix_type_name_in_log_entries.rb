class FixTypeNameInLogEntries < ActiveRecord::Migration
  def change
    rename_column :log_entries, :type, :event_type
  end
end
