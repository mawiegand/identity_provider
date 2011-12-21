class AddActivatedToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :activated, :timestamp, :null => true, :default => :null
  end
end
