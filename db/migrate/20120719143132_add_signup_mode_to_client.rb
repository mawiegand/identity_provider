class AddSignupModeToClient < ActiveRecord::Migration
  def change
    add_column :clients, :signup_mode, :integer, :default => 0, :null => false
  end
end
