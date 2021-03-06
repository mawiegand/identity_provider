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

ActiveRecord::Schema.define(:version => 20141117141547) do

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

  create_table "game_game_instances", :force => true do |t|
    t.integer  "game_id"
    t.string   "scope"
    t.integer  "number"
    t.string   "name"
    t.text     "localized_name"
    t.text     "description"
    t.text     "localized_description"
    t.datetime "available_since"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.boolean  "signin_enabled",                   :default => true,  :null => false
    t.boolean  "signup_enabled",                   :default => true,  :null => false
    t.boolean  "insider_only",                     :default => false, :null => false
    t.boolean  "testing",                          :default => false, :null => false
    t.decimal  "speed_factor",                     :default => 1.0,   :null => false
    t.integer  "estimated_duration_min"
    t.integer  "estimated_duration_max"
    t.boolean  "multi_language",                   :default => true,  :null => false
    t.text     "language_codes"
    t.integer  "max_players"
    t.integer  "present_players",                  :default => 0,     :null => false
    t.boolean  "hidden",                           :default => true,  :null => false
    t.boolean  "hidden_for_non_insiders",          :default => false, :null => false
    t.text     "restriction_country_codes"
    t.text     "restriction_language_codes"
    t.decimal  "restriction_latitude"
    t.decimal  "restriction_longitude"
    t.decimal  "restriction_latitude_max"
    t.decimal  "restriction_longitude_max"
    t.decimal  "restriction_distance_to_position"
    t.string   "restriction_postal_code"
    t.string   "server_types"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_scheduled_game_downtimes", :force => true do |t|
    t.integer  "game_instance_id"
    t.datetime "start_scheduled_at"
    t.datetime "end_scheduled_at"
    t.datetime "ended_at"
    t.integer  "type_id"
    t.text     "description"
    t.text     "localized_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_scheduled_server_downtimes", :force => true do |t|
    t.integer  "server_id"
    t.datetime "start_scheduled_at"
    t.datetime "end_scheduled_at"
    t.datetime "ended_at"
    t.integer  "type_id"
    t.text     "description"
    t.text     "localized_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_servers", :force => true do |t|
    t.integer  "game_instance_id"
    t.string   "type_string"
    t.string   "hostname"
    t.integer  "port"
    t.string   "protocol"
    t.string   "namespace"
    t.string   "ip"
    t.boolean  "online",           :default => true, :null => false
    t.datetime "available_since"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer  "num_payments",              :default => 0,     :null => false
    t.integer  "num_chargebacks",           :default => 0,     :null => false
    t.decimal  "earnings",                  :default => 0.0,   :null => false
    t.decimal  "chargeback_costs",          :default => 0.0,   :null => false
    t.datetime "first_payment"
    t.datetime "platinum_lifetime_since"
    t.datetime "divine_supporter_since"
    t.integer  "image_set_id"
    t.string   "gender"
    t.string   "fb_name"
    t.string   "fb_birthday"
    t.string   "fb_age_range"
    t.string   "fb_username"
    t.string   "ref_id"
    t.string   "sub_id"
  end

  add_index "identities", ["email"], :name => "index_identities_on_email", :unique => true
  add_index "identities", ["identifier"], :name => "index_identities_on_identifier", :unique => true

  create_table "install_tracking_device_users", :force => true do |t|
    t.integer  "identity_id"
    t.integer  "device_id"
    t.datetime "first_use_at"
    t.datetime "last_use_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "confirmed_at"
    t.integer  "auth_count",   :default => 0, :null => false
  end

  add_index "install_tracking_device_users", ["auth_count"], :name => "index_install_tracking_device_users_on_auth_count"

  create_table "install_tracking_devices", :force => true do |t|
    t.integer  "platform_id"
    t.string   "hardware_string"
    t.integer  "hardware_id"
    t.string   "operating_system"
    t.string   "device_token"
    t.boolean  "suspicious",          :default => false, :null => false
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
    t.string   "ref_id"
    t.string   "sub_id"
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

  add_index "log_entries", ["created_at"], :name => "index_log_entries_on_created_at"
  add_index "log_entries", ["event_type"], :name => "index_log_entries_on_event_type"
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

  create_table "shop_fb_payments_logs", :force => true do |t|
    t.integer  "identity_id"
    t.string   "payment_id"
    t.string   "username"
    t.string   "fb_user_id"
    t.string   "action_type"
    t.string   "status"
    t.string   "currency"
    t.string   "amount"
    t.string   "time_created"
    t.string   "time_updated"
    t.string   "product_url"
    t.integer  "quantity"
    t.string   "country"
    t.integer  "sandbox"
    t.string   "fraud_status"
    t.decimal  "payout_foreign_exchange_rate"
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
    t.boolean  "tracked",                  :default => false, :null => false
    t.boolean  "chargeback_tracked",       :default => false, :null => false
  end

  create_table "tracking_callbacks", :force => true do |t|
    t.string   "service"
    t.string   "remote_ip"
    t.text     "http_request"
    t.string   "device_id"
    t.string   "refid"
    t.string   "subid"
    t.datetime "connected_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
