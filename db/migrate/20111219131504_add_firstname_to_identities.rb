class AddFirstnameToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :firstname, :string
  end
end
