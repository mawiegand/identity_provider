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
      t.boolean :signin_enabled,          default: true,  null: false
      t.boolean :signup_enabled,          default: true,  null: false
      t.boolean :insider_only,            default: false, null: false
      t.boolean :testing,                 default: false, null: false
      t.decimal :speed_factor,            default: 1.0,   null: false
      t.integer :estimated_duration_min
      t.integer :estimated_duration_max
      t.boolean :multi_language,          default: true,  null: false
      t.text :language_codes
      t.integer :max_players
      t.integer :present_players,         default: 0,     null: false
      t.boolean :hidden,                  default: true,  null: false
      t.boolean :hidden_for_non_insiders, default: false, null: false
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
