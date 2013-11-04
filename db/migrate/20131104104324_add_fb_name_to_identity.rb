class AddFbNameToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :fb_name, :string
    add_column :identities, :fb_birthday, :string
    add_column :identities, :fb_age_range, :string
    add_column :identities, :fb_username, :string
  end
end
