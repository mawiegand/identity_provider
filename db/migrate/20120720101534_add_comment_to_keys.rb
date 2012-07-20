class AddCommentToKeys < ActiveRecord::Migration
  def change
    add_column :keys, :comment, :text
  end
end
