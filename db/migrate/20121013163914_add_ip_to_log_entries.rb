class AddIpToLogEntries < ActiveRecord::Migration
  def change
    add_column :log_entries, :ip, :string
  end
end
