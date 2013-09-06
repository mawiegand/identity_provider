class CreateGameGameInstances < ActiveRecord::Migration
  def change
    create_table :game_game_instances do |t|
      t.integer :game_id
      t.string :scope
      t.integer :number
      t.string :name
      t.text :localized_name
      t.text :description
      t.text :localized_description
      t.datetime :available_since
      t.datetime :started_at
      t.datetime :ended_at
      t.boolean :signin_enabled
      t.boolean :signup_enabled
      t.boolean :insider_only
      t.boolean :testing
      t.decimal :speed_factor
      t.integer :estimated_duration_min
      t.integer :estimated_duration_max
      t.boolean :multi_language
      t.text :language_codes
      t.integer :max_players
      t.boolean :present_players
      t.boolean :hidden
      t.boolean :hidden_for_non_insiders
      t.text :restriction_country_codes
      t.text :restriction_language_codes
      t.decimal :restriction_latitude
      t.decimal :restriction_longitude
      t.decimal :restriction_latitude_max
      t.decimal :restriction_longitude_max
      t.decimal :restriction_distance_to_position
      t.string :restriction_postal_code
      t.string :server_types

      t.timestamps
    end
  end
end
