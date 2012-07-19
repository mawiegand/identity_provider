class CreateGrantedScopes < ActiveRecord::Migration
  def change
    create_table :granted_scopes do |t|
      t.integer :identity_id
      t.integer :client_id
      t.string :scopes
      t.integer :key_id

      t.timestamps
    end
  end
end
