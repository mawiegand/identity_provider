class AddDirectBackendLoginUrlToClient < ActiveRecord::Migration
  def change
    add_column :clients, :direct_backend_login_url, :string
  end
end
