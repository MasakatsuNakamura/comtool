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

ActiveRecord::Schema.define(version: 20170419070037) do

  create_table "com_signals", force: :cascade do |t|
    t.string   "name",                     collation: "NOCASE"
    t.integer  "message_id"
    t.string   "unit"
    t.string   "description"
    t.integer  "layout"
    t.integer  "bit_offset"
    t.integer  "bit_size"
    t.integer  "sign_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["message_id", "name"], name: "index_com_signals_on_message_id_and_name", unique: true
    t.index ["message_id"], name: "index_com_signals_on_message_id"
    t.index ["sign_id"], name: "index_com_signals_on_sign_id"
  end

  create_table "communication_protocols", force: :cascade do |t|
    t.string   "protocol_number"
    t.string   "name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "configs", force: :cascade do |t|
    t.string   "item"
    t.string   "value"
    t.string   "description"
    t.integer  "project_id"
    t.integer  "sign_id"
    t.integer  "message_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["message_id"], name: "index_configs_on_message_id"
    t.index ["project_id"], name: "index_configs_on_project_id"
    t.index ["sign_id"], name: "index_configs_on_sign_id"
  end

  create_table "database_manages", force: :cascade do |t|
    t.string   "backup_file_path"
    t.date     "backup_date"
    t.integer  "project_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["project_id"], name: "index_database_manages_on_project_id"
  end

  create_table "members", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_members_on_project_id"
    t.index ["user_id"], name: "index_members_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string   "name",                    collation: "NOCASE"
    t.integer  "canid"
    t.integer  "txrx"
    t.integer  "baudrate"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "bytesize"
    t.index ["project_id", "name"], name: "index_messages_on_project_id_and_name", unique: true
    t.index ["project_id"], name: "index_messages_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name",                                   collation: "NOCASE"
    t.integer  "communication_protocol_id"
    t.integer  "qines_version_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["communication_protocol_id"], name: "index_projects_on_communication_protocol_id"
    t.index ["name"], name: "index_projects_on_name", unique: true
    t.index ["qines_version_id"], name: "index_projects_on_qines_version_id"
  end

  create_table "qines_versions", force: :cascade do |t|
    t.string   "qines_version_number"
    t.string   "name"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "signs", force: :cascade do |t|
    t.string   "name"
    t.integer  "active"
    t.integer  "vartype"
    t.string   "unit"
    t.float    "exchange_rate"
    t.integer  "priority"
    t.integer  "input_module"
    t.integer  "output_moduel"
    t.integer  "input_period"
    t.integer  "output_period"
    t.integer  "access_level"
    t.string   "description"
    t.integer  "project_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["project_id"], name: "index_signs_on_project_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "config_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["config_id"], name: "index_tags_on_config_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
    t.string   "remember_token"
    t.string   "password"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
