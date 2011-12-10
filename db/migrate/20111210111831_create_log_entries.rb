class CreateLogEntries < ActiveRecord::Migration
  def change
    create_table :log_entries do |t|
      t.references :identity
      t.string :role
      t.string :affected_table
      t.integer :affected_id
      t.string :type
      t.string :description

      t.timestamps
    end
    add_index :log_entries, :identity_id
    add_index :log_entries, :type
  end
end
