class AddEncryptedPasswordToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :encrypted_password, :string
    remove_column :identities, :password
  end
end
