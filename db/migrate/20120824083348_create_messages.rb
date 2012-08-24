class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer  :recipient_id
      t.string   :recipient_character_name
      t.integer  :game_id
      t.datetime :received_at
      t.datetime :delivered_at
      t.string   :delivered_via
      t.boolean  :read,                      :default => false, :null => false
      t.string   :subject
      t.text     :body
      t.string   :sender_character_name
      t.integer  :sender_id
      t.boolean  :system_message

      t.timestamps
    end
  end
end
