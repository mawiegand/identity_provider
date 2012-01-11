class AddIdentifierToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :identifier, :string, :null => false, :default => 'a'
  end
end
