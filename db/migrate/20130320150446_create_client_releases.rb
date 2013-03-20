class CreateClientReleases < ActiveRecord::Migration
  def change
    create_table :client_releases do |t|
      t.integer :client_id
      t.string :version
      t.string :name
      t.text :notes
      t.datetime :rejected_at
      t.text :rejection_reason
      t.integer :rejecting_identity_id

      t.timestamps
    end
  end
end
