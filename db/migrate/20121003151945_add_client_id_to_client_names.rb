class AddClientIdToClientNames < ActiveRecord::Migration
  def change
    add_column :client_names, :client_id, :integer
  end
end
