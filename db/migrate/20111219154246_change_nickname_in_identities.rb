class ChangeNicknameInIdentities < ActiveRecord::Migration
  def change
    remove_column :identities, :nickname
    add_column :identities, :nickname, :string, :null => true
  end

end
