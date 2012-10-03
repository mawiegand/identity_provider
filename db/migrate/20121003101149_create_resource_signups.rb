class CreateResourceSignups < ActiveRecord::Migration
  def change
    create_table :resource_signups do |t|
      t.integer :client_id
      t.integer :identity_id
      t.string :invitation
      t.boolean :automatic
      t.string :ip

      t.timestamps
    end
  end
end
