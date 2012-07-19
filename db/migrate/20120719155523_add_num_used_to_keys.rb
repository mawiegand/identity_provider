class AddNumUsedToKeys < ActiveRecord::Migration
  def change
    add_column :keys, :num_used, :integer, {:default => 0, :null => false}
  end
end
