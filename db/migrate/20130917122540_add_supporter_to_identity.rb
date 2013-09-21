class AddSupporterToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :supporter_since, :datetime
  end
end
