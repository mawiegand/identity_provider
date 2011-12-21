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

ActiveRecord::Schema.define(:version => 20111221094027) do

  create_table "identities", :force => true do |t|
    t.string   "email"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.boolean  "admin",              :limit => 255
    t.boolean  "staff",              :limit => 255
    t.string   "firstname"
    t.string   "surname"
    t.string   "nickname"
    t.boolean  "deleted",                           :default => false
    t.datetime "activated"
  end

  add_index "identities", ["email"], :name => "index_identities_on_email", :unique => true

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
