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

ActiveRecord::Schema.define(version: 20150609163339) do

  create_table "partners", force: :cascade do |t|
    t.integer  "min_age",      limit: 4
    t.integer  "max_age",      limit: 4
    t.integer  "user_id",      limit: 4
    t.integer  "sexuality_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "partners", ["sexuality_id"], name: "index_partners_on_sexuality_id", using: :btree
  add_index "partners", ["user_id"], name: "index_partners_on_user_id", using: :btree

  create_table "partners_styles", id: false, force: :cascade do |t|
    t.integer "partner_id", limit: 4
    t.integer "style_id",   limit: 4
  end

  add_index "partners_styles", ["partner_id"], name: "index_partners_styles_on_partner_id", using: :btree
  add_index "partners_styles", ["style_id"], name: "index_partners_styles_on_style_id", using: :btree

  create_table "partners_zodiacs", id: false, force: :cascade do |t|
    t.integer "partner_id", limit: 4
    t.integer "zodiac_id",  limit: 4
  end

  add_index "partners_zodiacs", ["partner_id"], name: "index_partners_zodiacs_on_partner_id", using: :btree
  add_index "partners_zodiacs", ["zodiac_id"], name: "index_partners_zodiacs_on_zodiac_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.date     "birthday"
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "gender",     limit: 4
    t.integer  "zodiac_id",  limit: 4
    t.integer  "style_id",   limit: 4
    t.string   "avatar",     limit: 255
  end

  add_index "profiles", ["style_id"], name: "index_profiles_on_style_id", using: :btree
  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree
  add_index "profiles", ["zodiac_id"], name: "index_profiles_on_zodiac_id", using: :btree

  create_table "sexualities", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "styles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "gender",     limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",        limit: 255
    t.string   "email",           limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "password_digest", limit: 255
    t.string   "remember_digest", limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "zodiacs", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_foreign_key "partners", "sexualities"
  add_foreign_key "partners", "users"
  add_foreign_key "profiles", "styles"
  add_foreign_key "profiles", "users"
  add_foreign_key "profiles", "zodiacs"
end
