class CreateResourceGames < ActiveRecord::Migration
  def change
    create_table :resource_games do |t|
      t.string :name
      t.string :scopes
      t.string :link
      t.string :shared_secret

      t.timestamps
    end
  end
end
