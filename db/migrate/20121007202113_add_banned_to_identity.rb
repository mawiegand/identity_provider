class AddBannedToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :banned, :boolean 
    add_column :identities, :ban_reason, :string
    add_column :identities, :ban_ended_at, :datetime
  end
end
