class ChangeNameFieldInIdentities < ActiveRecord::Migration
  def change
    rename_column :identities, :name, :nickname
  end
end
