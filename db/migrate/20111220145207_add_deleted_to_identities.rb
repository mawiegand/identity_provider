class AddDeletedToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :deleted, :boolean, :default => false
  end
end
