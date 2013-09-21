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

  # カテゴリー 
  create_table "categories", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end
  
  # サブカテゴリー
  create_table "sub_categories", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end
    
  # サイト
  create_table "sites", :force => true do |t|
    t.string     "title",       :null => false
    t.string     "url",         :null => false
    t.string     "feed_url",    :null => true
    t.references :category,     :default => 1
    t.references :sub_category, :default => 0
    t.string     "registered_from"
    t.integer    "rank"
    t.datetime   "created_at",  :null => false
    t.datetime   "updated_at",  :null => false
  end

  add_index "sites", ["url"], :name => "sites_unique_url", :unique => true

  # 記事（ブログ記事、ニュース記事）
  create_table "articles", :force => true do |t|
    t.string   "title",        :null => false
    t.string   "url",          :null => false
    t.references :site,        :null => false
    t.integer  "tw_count",     :default => 0
    t.integer  "fb_count",     :default => 0    
    t.datetime "published",    :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "articles", ["url"], :name => "articles_unique_url", :unique => true
    
  # エントリー（ブログ記事、ニュース記事など）
  create_table "entries", :force => true do |t|
    t.string   "title",        :null => false
    t.string   "url",          :null => false
    t.references :site,        :null => false
    t.references :category,    :default => 0
    t.string   "description",  :null => true
    t.integer  "tw_count",     :default => 0
    t.integer  "fb_count",     :default => 0    
    t.integer  "ht_count",     :default => 0    
    t.datetime "published",    :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "entries", ["url"], :name => "entries_unique_url", :unique => true
  
  # エントリーに対するSNSでのコメント（Twitter、Facebook）
  create_table "comments", :force => true do |t|
    t.string   "text",          :null => false
    t.string   "url",           :null => true
    t.string   "user_name",     :null => true
    t.string   "user_account",  :null => true
    t.string   "icon_url",      :null => true
    t.string   "sns_name",      :default => "twitter"
    t.references :entry,        :null => false
    t.datetime "published",     :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end
    
  # ブログランキングのページ（サイト登録用）
  create_table "blog_rank_pages", :force => true do |t|
    t.string     "title",        :null => false
    t.string     "url",          :null => false
    t.string     "feed_url"  
    t.references :category
    t.references :sub_category
    t.string     "blog_service_name"
    t.integer    "max_register_count", :default => 25  
    t.datetime   "created_at",         :null => false
    t.datetime   "updated_at",         :null => false
  end
  
      
  # 以下、削除候補  
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
    
end
