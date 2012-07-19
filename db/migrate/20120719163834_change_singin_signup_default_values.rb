class ChangeSinginSignupDefaultValues < ActiveRecord::Migration
  def up
    change_column :clients, :signup_mode, :integer, :default => 1, :null => false
    change_column :clients, :signin_mode, :integer, :default => 1, :null => false
  end

  def down
    change_column :clients, :signup_mode, :integer, :default => 0, :null => false
    change_column :clients, :signin_mode, :integer, :default => 0, :null => false
  end
end
