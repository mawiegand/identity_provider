class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :identifier
      t.string :name
      t.integer :identity_id
      t.string :password
      t.string :refresh_token_secret
      t.text :description
      t.string :homepage
      t.string :grant_types
      t.string :scopes

      t.timestamps
    end
  end
end
