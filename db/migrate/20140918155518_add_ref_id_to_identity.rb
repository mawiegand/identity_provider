class AddRefIdToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :ref_id, :string
    add_column :identities, :sub_id, :string
  end
end
