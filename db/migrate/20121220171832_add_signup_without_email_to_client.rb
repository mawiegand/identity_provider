class AddSignupWithoutEmailToClient < ActiveRecord::Migration
  def change
    add_column :clients,    :signup_without_email, :boolean, :default => false, :null => false
    add_column :identities, :generic_nickname,     :boolean, :default => false, :null => false
    add_column :identities, :generic_email,        :boolean, :default => false, :null => false
  end
end
