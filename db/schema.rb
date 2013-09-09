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

ActiveRecord::Schema.define(:version => 20130901144608) do

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.references :site
    #t.integer  "tw_retweet",   :default => 0
    #t.integer  "fb_share",     :default => 0
    t.integer  "tw_count",     :default => 0
    t.integer  "fb_count",     :default => 0    
    t.datetime "published"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "articles", ["url"], :name => "articles_unique_url", :unique => true

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "keywords", :force => true do |t|
    t.string   "name"
    t.integer  "dupli_count"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "news", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.integer  "site_id"
    t.datetime "published_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "news", ["url"], :name => "news_unique_url", :unique => true

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "feed_url"
    #t.integer  "category_id",     :default => 3
    t.references :category, :default => 3
    t.string   "registered_from"
    t.integer  "rank"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "sites", ["url"], :name => "sites_unique_url", :unique => true

end
