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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150727115600) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "apis", force: :cascade do |t|
    t.string "name", null: false
  end

  add_index "apis", ["name"], name: "index_apis_on_name", using: :btree

  create_table "days", force: :cascade do |t|
    t.integer  "sym_id",     null: false
    t.date     "date",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "days", ["date"], name: "index_days_on_date", using: :btree
  add_index "days", ["sym_id"], name: "index_days_on_sym_id", using: :btree

  create_table "favorite_syms", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "sym_id",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "favorite_syms", ["sym_id"], name: "index_favorite_syms_on_sym_id", using: :btree
  add_index "favorite_syms", ["user_id"], name: "index_favorite_syms_on_user_id", using: :btree

  create_table "historical_data", force: :cascade do |t|
    t.integer  "sym_id",        null: false
    t.date     "date",          null: false
    t.decimal  "opening_price"
    t.decimal  "closing_price"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "historical_data", ["closing_price"], name: "index_historical_data_on_closing_price", using: :btree
  add_index "historical_data", ["opening_price"], name: "index_historical_data_on_opening_price", using: :btree
  add_index "historical_data", ["sym_id"], name: "index_historical_data_on_sym_id", using: :btree

  create_table "markets", force: :cascade do |t|
    t.string   "name",             null: false
    t.decimal  "hour_opens",       null: false
    t.decimal  "hour_closes",      null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.date     "last_day_curated"
  end

  add_index "markets", ["name"], name: "index_markets_on_name", using: :btree

  create_table "syms", force: :cascade do |t|
    t.integer  "market_id",                                 null: false
    t.integer  "historical_api_id"
    t.integer  "intraday_api_id"
    t.string   "name",                                      null: false
    t.string   "full_name"
    t.decimal  "current_price"
    t.decimal  "volatility"
    t.datetime "last_updated_tick_time"
    t.boolean  "currently_collecting_data", default: false
    t.boolean  "showing_patterns"
    t.boolean  "historical_data_logged"
    t.boolean  "intraday_log_error"
    t.boolean  "disabled"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "syms", ["current_price"], name: "index_syms_on_current_price", using: :btree
  add_index "syms", ["disabled"], name: "index_syms_on_disabled", using: :btree
  add_index "syms", ["full_name"], name: "index_syms_on_full_name", using: :btree
  add_index "syms", ["historical_api_id"], name: "index_syms_on_historical_api_id", using: :btree
  add_index "syms", ["intraday_api_id"], name: "index_syms_on_intraday_api_id", using: :btree
  add_index "syms", ["market_id"], name: "index_syms_on_market_id", using: :btree
  add_index "syms", ["name"], name: "index_syms_on_name", using: :btree
  add_index "syms", ["volatility"], name: "index_syms_on_volatility", using: :btree

  create_table "ticks", force: :cascade do |t|
    t.datetime "time",       null: false
    t.decimal  "amount",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "day_id"
  end

  add_index "ticks", ["amount"], name: "index_ticks_on_amount", using: :btree
  add_index "ticks", ["time"], name: "index_ticks_on_time", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "image_link"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "admin",            default: false
  end

end
