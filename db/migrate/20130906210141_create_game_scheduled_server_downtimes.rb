class CreateGameScheduledServerDowntimes < ActiveRecord::Migration
  def change
    create_table :game_scheduled_server_downtimes do |t|
      t.integer :server_id
      t.datetime :start_scheduled_at
      t.datetime :end_scheduled_at
      t.datetime :ended_at
      t.integer :type_id
      t.text :description
      t.text :localized_description

      t.timestamps
    end
  end
end
