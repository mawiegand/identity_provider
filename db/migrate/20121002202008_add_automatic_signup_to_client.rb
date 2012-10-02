class AddAutomaticSignupToClient < ActiveRecord::Migration
  def change
    add_column :clients, :automatic_signup, :boolean,   :default => false, :null => false
  end
end
