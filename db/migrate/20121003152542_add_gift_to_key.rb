class AddGiftToKey < ActiveRecord::Migration
  def change
    add_column :keys, :gift, :text
  end
end
