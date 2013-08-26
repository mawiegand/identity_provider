# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130826164637) do

  create_table "client_names", :force => true do |t|
    t.string   "lang"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
  end

  create_table "client_releases", :force => true do |t|
    t.integer  "client_id"
    t.string   "version"
    t.string   "name"
    t.text     "notes"
    t.datetime "rejected_at"
    t.text     "rejection_reason"
    t.integer  "rejecting_identity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients", :force => true do |t|
    t.string   "identifier"
    t.string   "name"
    t.integer  "identity_id"
    t.string   "password"
    t.string   "refresh_token_secret"
    t.text     "description"
    t.string   "homepage"
    t.string   "grant_types"
    t.string   "scopes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "signup_mode",              :default => 1,     :null => false
    t.integer  "signin_mode",              :default => 1,     :null => false
    t.boolean  "automatic_signup",         :default => false, :null => false
    t.string   "direct_backend_login_url"
    t.boolean  "signup_without_email",     :default => false, :null => false
  end

  create_table "granted_scopes", :force => true do |t|
    t.integer  "identity_id"
    t.integer  "client_id"
    t.string   "scopes"
    t.integer  "key_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "identities", :force => true do |t|
    t.string   "email"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.boolean  "admin"
    t.boolean  "staff"
    t.string   "firstname"
    t.string   "surname"
    t.string   "nickname"
    t.boolean  "deleted",                   :default => false
    t.datetime "activated"
    t.string   "identifier",                :default => "a",   :null => false
    t.integer  "sign_up_with_client_id"
    t.string   "password_token"
    t.string   "locale"
    t.boolean  "banned"
    t.string   "ban_reason"
    t.datetime "ban_ended_at"
    t.string   "referer"
    t.boolean  "generic_nickname",          :default => false, :null => false
    t.boolean  "generic_email",             :default => false, :null => false
    t.boolean  "generic_password",          :default => false, :null => false
    t.string   "gc_player_id"
    t.datetime "gc_rejected_at"
    t.datetime "gc_player_id_connected_at"
    t.datetime "insider_since"
    t.integer  "age_in_hours",              :default => 0,     :null => false
    t.integer  "age_days",                  :default => 0,     :null => false
    t.string   "fb_player_id"
    t.datetime "fb_rejected_at"
    t.datetime "fb_player_id_connected_at"
  end

  add_index "identities", ["email"], :name => "index_identities_on_email", :unique => true

  create_table "install_tracking_device_users", :force => true do |t|
    t.integer  "identity_id"
    t.integer  "device_id"
    t.datetime "first_use_at"
    t.datetime "last_use_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "confirmed_at"
  end

  create_table "install_tracking_devices", :force => true do |t|
    t.integer  "platform_id"
    t.string   "hardware_string"
    t.integer  "hardware_id"
    t.string   "operating_system"
    t.string   "device_token"
    t.boolean  "suspicious"
    t.text     "note"
    t.datetime "banned_at"
    t.text     "ban_reason"
    t.integer  "banning_identity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "old_token"
    t.string   "vendor_token"
    t.string   "advertiser_token"
    t.string   "hardware_token"
  end

  create_table "install_tracking_install_users", :force => true do |t|
    t.integer  "identity_id"
    t.integer  "install_id"
    t.datetime "last_use_at"
    t.datetime "first_use_at"
    t.integer  "sign_in_count",   :default => 0, :null => false
    t.string   "last_ip_address"
    t.string   "last_latitude"
    t.string   "last_longitude"
    t.datetime "last_postion_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "confirmed_at"
  end

  create_table "install_tracking_installs", :force => true do |t|
    t.integer  "release_id"
    t.integer  "device_id"
    t.string   "app_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "install_tracking_push_notification_tokens", :force => true do |t|
    t.string   "push_notification_token"
    t.string   "device_token"
    t.string   "identifier"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "install_tracking_tracking_events", :force => true do |t|
    t.string   "device_token"
    t.string   "event_name"
    t.string   "event_args"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "old_token"
  end

  create_table "keys", :force => true do |t|
    t.integer  "client_id"
    t.string   "key"
    t.integer  "number",     :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_used",   :default => 0, :null => false
    t.text     "comment"
    t.text     "gift"
  end

  create_table "log_entries", :force => true do |t|
    t.integer  "identity_id"
    t.string   "role"
    t.string   "affected_table"
    t.integer  "affected_id"
    t.string   "event_type"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip"
  end

  add_index "log_entries", ["event_type"], :name => "index_log_entries_on_type"
  add_index "log_entries", ["identity_id"], :name => "index_log_entries_on_identity_id"

  create_table "messages", :force => true do |t|
    t.integer  "recipient_id"
    t.string   "recipient_character_name"
    t.integer  "game_id"
    t.datetime "received_at"
    t.datetime "delivered_at"
    t.string   "delivered_via"
    t.boolean  "read",                     :default => false, :null => false
    t.string   "subject"
    t.text     "body"
    t.string   "sender_character_name"
    t.integer  "sender_id"
    t.boolean  "system_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "redirects", :force => true do |t|
    t.integer  "identity_id"
    t.string   "origin"
    t.string   "destination"
    t.string   "agent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_character_properties", :force => true do |t|
    t.integer  "game_id"
    t.integer  "identity_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_device_users", :force => true do |t|
    t.integer  "identity_id"
    t.integer  "platform_id",      :default => 0, :null => false
    t.integer  "hardware_id"
    t.string   "gc_player_id"
    t.string   "os"
    t.string   "device_token"
    t.datetime "first_sign_in_at"
    t.datetime "last_sign_in_at"
    t.integer  "sign_in_count",    :default => 0, :null => false
    t.string   "last_ip_address"
    t.string   "last_latitude"
    t.string   "last_longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
    t.string   "version"
    t.string   "hardware_string"
    t.string   "client_token"
  end

  create_table "resource_games", :force => true do |t|
    t.string   "name"
    t.string   "scopes"
    t.string   "link"
    t.string   "shared_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier"
  end

  create_table "resource_histories", :force => true do |t|
    t.integer  "game_id"
    t.integer  "identity_id"
    t.text     "data"
    t.text     "localized_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_results", :force => true do |t|
    t.integer  "game_id"
    t.integer  "identity_id"
    t.string   "round_name"
    t.integer  "round_number"
    t.integer  "individual_rank"
    t.integer  "alliance_rank"
    t.string   "alliance_tag"
    t.string   "alliance_name"
    t.string   "character_name"
    t.boolean  "won"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_signup_gifts", :force => true do |t|
    t.integer  "identity_id"
    t.integer  "client_id"
    t.integer  "key_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_signups", :force => true do |t|
    t.integer  "client_id"
    t.integer  "identity_id"
    t.string   "invitation"
    t.boolean  "automatic"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "key_id"
    t.string   "referer"
    t.text     "request_url"
  end

  create_table "resource_waiting_lists", :force => true do |t|
    t.integer  "client_id"
    t.integer  "identity_id"
    t.integer  "key_id"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stats_money_transactions", :force => true do |t|
    t.integer  "identity_id"
    t.integer  "uid"
    t.integer  "tstamp"
    t.string   "updatetstamp"
    t.integer  "user_id"
    t.string   "invoice_id"
    t.string   "title_id"
    t.string   "method"
    t.string   "carrier"
    t.string   "country"
    t.integer  "offer_id"
    t.string   "offer_category"
    t.decimal  "gross"
    t.string   "gross_currency"
    t.decimal  "exchange_rate"
    t.decimal  "vat"
    t.decimal  "tax"
    t.decimal  "net"
    t.decimal  "fee"
    t.decimal  "ebp"
    t.string   "referrer_id"
    t.decimal  "referrer_share"
    t.decimal  "earnings"
    t.decimal  "chargeback"
    t.string   "campaign_id"
    t.boolean  "transaction_payed"
    t.string   "transaction_state"
    t.string   "comment"
    t.string   "scale_factor"
    t.string   "user_mail"
    t.string   "payment_transaction_uid"
    t.string   "payment_state"
    t.string   "payment_state_reason"
    t.string   "payer_id"
    t.string   "payer_first_name"
    t.string   "payer_last_name"
    t.string   "payer_mail"
    t.string   "payer_zip"
    t.string   "payer_city"
    t.string   "payer_street"
    t.string   "payer_country"
    t.string   "payer_state"
    t.string   "hash"
    t.string   "seed"
    t.string   "partner_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sent_mail_alert"
    t.boolean  "sent_special_offer_alert"
    t.boolean  "recurring"
    t.boolean  "sandbox",                  :default => false, :null => false
  end

end
