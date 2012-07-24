class AddIdentifierToResourceGame < ActiveRecord::Migration
  def change
    add_column :resource_games, :identifier, :string
  end
end
