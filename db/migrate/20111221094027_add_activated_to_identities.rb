class AddActivatedToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :activated, :timestamp, :null => true
  end
end
