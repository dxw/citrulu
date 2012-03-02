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

ActiveRecord::Schema.define(:version => 20120302161929) do

  create_table "results", :force => true do |t|
    t.integer  "test_file_id"
    t.time     "time_run"
    t.text     "result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_files", :force => true do |t|
    t.text     "test_file_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.text     "compiled_test_file_text"
  end

  create_table "test_groups", :force => true do |t|
    t.integer  "test_run_id"
    t.text     "page_content"
    t.integer  "response_time"
    t.time     "time_run"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_results", :force => true do |t|
    t.integer  "test_group_id"
    t.string   "assertion"
    t.string   "value"
    t.string   "name"
    t.boolean  "result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_runs", :force => true do |t|
    t.integer  "test_file_id"
    t.time     "time_run"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tests", :force => true do |t|
    t.integer  "test_group_id"
    t.string   "assertion"
    t.string   "value"
    t.string   "name"
    t.boolean  "result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
