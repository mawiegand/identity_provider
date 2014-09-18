class CreateTrackingCallbacks < ActiveRecord::Migration
  def change
    create_table :tracking_callbacks do |t|
      t.string   :service
      t.string   :remote_ip
      t.text     :http_request
      t.string   :device_id
      t.string   :refid
      t.string   :subid
      t.datetime :connected_at, :default => false, :null => false

      t.timestamps
    end
  end
end
