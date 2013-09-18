class AddImageSetIdToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :image_set_id, :integer
  end
end
