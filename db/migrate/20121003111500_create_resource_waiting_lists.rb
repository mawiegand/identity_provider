class CreateResourceWaitingLists < ActiveRecord::Migration
  def change
    create_table :resource_waiting_lists do |t|
      t.integer :client_id
      t.integer :identity_id
      t.integer :key_id
      t.string :ip

      t.timestamps
    end
  end
end
