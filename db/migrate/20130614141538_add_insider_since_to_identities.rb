class AddInsiderSinceToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :insider_since, :datetime
  end
end
