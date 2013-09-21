class RenameAttributeOfIdentity < ActiveRecord::Migration
  def change
    rename_column :identities, :supporter_since, :divine_supporter_since
  end
end
