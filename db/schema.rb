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

ActiveRecord::Schema.define(:version => 20120425180805) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
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
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "invitations", :force => true do |t|
    t.string   "code"
    t.string   "description"
    t.boolean  "enabled"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "plans", :force => true do |t|
    t.integer  "test_frequency"
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
    t.string   "name_en"
    t.boolean  "default"
    t.integer  "spreedly_id"
    t.boolean  "active"
    t.integer  "number_of_sites",          :limit => 255
    t.integer  "mobile_alerts_allowance",  :limit => 255
    t.boolean  "allows_custom_predefines"
    t.boolean  "allows_retrieved_pages"
    t.boolean  "allows_git_support"
    t.boolean  "allows_tests_on_demand"
    t.decimal  "cost_usd",                                :precision => 6, :scale => 2
  end

  add_index "plans", ["active", "name_en"], :name => "index_plans_on_active_and_name_en"
  add_index "plans", ["active", "spreedly_id"], :name => "index_plans_on_active_and_spreedly_id"

  create_table "responses", :force => true do |t|
    t.integer "response_time"
    t.string  "content_hash"
    t.text    "headers"
    t.text    "content"
    t.string  "code"
  end

  create_table "test_files", :force => true do |t|
    t.text     "test_file_text"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "user_id"
    t.text     "compiled_test_file_text"
    t.string   "name"
  end

  create_table "test_groups", :force => true do |t|
    t.integer  "test_run_id"
    t.text     "page_content"
    t.datetime "time_run"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "test_url"
    t.text     "message"
    t.string   "method"
    t.string   "so"
    t.text     "data"
    t.integer  "response_id"
  end

  create_table "test_results", :force => true do |t|
    t.integer  "test_group_id"
    t.boolean  "result"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "original_line"
  end

  create_table "test_runs", :force => true do |t|
    t.integer  "test_file_id"
    t.datetime "time_run"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",  :null => false
    t.string   "encrypted_password",     :default => "",  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "email_preference"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "invitation_id"
    t.integer  "plan_id"
    t.string   "status",                 :default => "t"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
