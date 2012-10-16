class CreateRedirects < ActiveRecord::Migration
  def change
    create_table :redirects do |t|
      t.integer :identity_id
      t.string :origin
      t.string :destination
      t.string :agent

      t.timestamps
    end
  end
end
