class AddSignUpWithClientIdToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :sign_up_with_client_id, :integer
  end
end
