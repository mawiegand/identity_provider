class CreateClientNames < ActiveRecord::Migration
  def change
    create_table :client_names do |t|
      t.string :lang
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
