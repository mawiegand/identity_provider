class AddUniquenessToIdentities < ActiveRecord::Migration
  def change
    add_index :identities, :email, :unique => true
    add_index :identities, :name, :unique => true
  end
end
