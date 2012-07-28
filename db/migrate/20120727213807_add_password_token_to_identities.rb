class AddPasswordTokenToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :password_token, :string
  end
end
