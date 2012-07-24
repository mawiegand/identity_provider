class CreateResourceHistories < ActiveRecord::Migration
  def change
    create_table :resource_histories do |t|
      t.integer :game_id
      t.integer :identity_id
      t.text :data
      t.text :localized_description

      t.timestamps
    end
  end
end
