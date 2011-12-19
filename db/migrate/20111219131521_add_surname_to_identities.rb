class AddSurnameToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :surname, :string
  end
end
