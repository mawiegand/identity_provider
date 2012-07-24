class CreateResourceResults < ActiveRecord::Migration
  def change
    create_table :resource_results do |t|
      t.integer :game_id
      t.integer :identity_id
      t.string :round_name
      t.integer :round_number
      t.integer :individual_rank
      t.integer :alliance_rank
      t.string :alliance_tag
      t.string :alliance_name
      t.string :character_name
      t.boolean :won

      t.timestamps
    end
  end
end
