class AddRefererToResourceSignup < ActiveRecord::Migration
  def change
    add_column :resource_signups, :referer, :string
  end
end
