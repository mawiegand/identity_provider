class AddLocaleToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :locale, :string
  end
end
