# coding: utf-8

#
#
#
class News < ActiveRecord::Base
  # attr_accessible :title, :body
  
  
  def new_action
    # sitesテーブルからデータ取得
    sites = Site.all
    
    # サイトの件数ループ
    sites.each do |site|
      feed_url = site.feed_url
      rss = RSS::Parser.parse(feed_url, false)
      #p rss
      
      rss.items.each do |item|
        news = News.new
        news.title = item.title
        news.url = item.link
        #p item
        begin
          if news.save
            p "保存できました"
          else
            p "保存できませんでした"
          end
        rescue => e
          p e.message
        end
      end

    end
      # RSSでデータを取得
    
    # newsテーブルに保存
  end
  
  #
  # 同じURLのデータが無ければDBに保存
  # 
  # @return [bool] 保存できればtrue
  def save_if_not_exists
    begin
      save
      p '保存に成功しました'
    rescue => e
      p '保存に失敗しました'
      p e.message
      return false
    end
    
    return true 
  end
  
end
