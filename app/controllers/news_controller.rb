# coding: utf-8
require "rss"

#
#
#
#
class NewsController < ApplicationController
  
  # sitesテーブルに登録されたサイトから、
  # 今日のニュースをRSSで取得してnewsテーブルに保存します。
  #
  def get_todays_post
    # sitesテーブルからデータ取得
    sites = Site.all
    # サイトの件数ループ
    
      # RSSでデータを取得
    
    # newsテーブルに保存
      
  end

  #
  #
  #
  def new
    action = News.new
    action.new_action
  end

  def index
  end
  
end

