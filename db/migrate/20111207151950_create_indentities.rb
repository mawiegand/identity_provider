class CreateIndentities < ActiveRecord::Migration
  def change
    create_table :indentities do |t|
      t.string :name
      t.string :email
      t.string :password
      t.string :salt

      t.timestamps
    end
  end
end
