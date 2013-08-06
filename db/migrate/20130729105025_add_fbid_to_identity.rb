class AddFbidToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :fb_player_id, :string
    add_column :identities, :fb_rejected_at, :datetime
    add_column :identities, :fb_player_id_connected_at, :datetime
  end
end
