class AddIdentifierToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :identifier, :string, :null => false
  end
end
