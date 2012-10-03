class CreateResourceSignupGifts < ActiveRecord::Migration
  def change
    create_table :resource_signup_gifts do |t|
      t.integer :identity_id
      t.integer :client_id
      t.integer :key_id
      t.text :data

      t.timestamps
    end
  end
end
