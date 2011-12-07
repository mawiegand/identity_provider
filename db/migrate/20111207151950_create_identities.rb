class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :name
      t.string :email
      t.string :password
      t.string :salt

      t.timestamps
    end
  end
end
