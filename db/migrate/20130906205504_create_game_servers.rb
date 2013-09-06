class CreateGameServers < ActiveRecord::Migration
  def change
    create_table :game_servers do |t|
      t.integer :game_instance_id
      t.string :type_string
      t.string :hostname
      t.integer :port
      t.string :protocol
      t.string :namespace
      t.string :ip
      t.boolean :online
      t.datetime :available_since
      t.datetime :ended_at

      t.timestamps
    end
  end
end
