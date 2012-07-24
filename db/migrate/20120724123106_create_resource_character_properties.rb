class CreateResourceCharacterProperties < ActiveRecord::Migration
  def change
    create_table :resource_character_properties do |t|
      t.integer :game_id
      t.integer :identity_id
      t.text :data

      t.timestamps
    end
  end
end
