class AddRequestUrlToResourceSignups < ActiveRecord::Migration
  def change
    add_column :resource_signups, :request_url, :text
  end
end
