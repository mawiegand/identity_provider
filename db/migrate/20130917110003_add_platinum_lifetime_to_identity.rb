class AddPlatinumLifetimeToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :platinum_lifetime_since, :datetime
  end
end
