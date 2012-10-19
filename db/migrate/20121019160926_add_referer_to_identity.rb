class AddRefererToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :referer, :string
  end
end
