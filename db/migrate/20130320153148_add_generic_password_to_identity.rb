class AddGenericPasswordToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :generic_password, :boolean, :default => false, :null => false
    add_column :identities, :gc_player_id, :string
    add_column :identities, :gc_rejected_at, :datetime
    add_column :identities, :gc_player_id_connected_at, :datetime
  end
end
