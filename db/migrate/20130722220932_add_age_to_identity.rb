class AddAgeToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :age_in_hours, :integer, :default => 0, :null => false
    add_column :identities, :age_days, :integer, :default => 0, :null => false
  end
end
