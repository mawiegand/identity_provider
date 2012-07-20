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

ActiveRecord::Schema.define(:version => 20120720101534) do

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
    t.integer  "signup_mode",          :default => 1, :null => false
    t.integer  "signin_mode",          :default => 1, :null => false
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
    t.boolean  "deleted",                :default => false
    t.datetime "activated"
    t.string   "identifier",             :default => "a",   :null => false
    t.integer  "sign_up_with_client_id"
  end

  add_index "identities", ["email"], :name => "index_identities_on_email", :unique => true

  create_table "keys", :force => true do |t|
    t.integer  "client_id"
    t.string   "key"
    t.integer  "number",     :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_used",   :default => 0, :null => false
    t.text     "comment"
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
  end

  add_index "log_entries", ["event_type"], :name => "index_log_entries_on_type"
  add_index "log_entries", ["identity_id"], :name => "index_log_entries_on_identity_id"

end
