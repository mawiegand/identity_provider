class CreateKeys < ActiveRecord::Migration
  def change
    create_table :keys do |t|
      t.integer :client_id
      t.string :key
      t.integer :number, :null => false, :default => 1

      t.timestamps
    end
  end
end
