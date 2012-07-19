class AddSigninModeToClient < ActiveRecord::Migration
  def change
    add_column :clients, :signin_mode, :integer, :default => 0, :null => false
  end
end
