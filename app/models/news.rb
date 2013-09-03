# coding: utf-8

#
#
#
class News < ActiveRecord::Base
  # attr_accessible :title, :body
 
   
  #
  # DBに登録しているサイトの今日のニュースをRSSで取得し、DBに保存
  #
  #
  def save_todays_news
    news_row = get_todays_news
    
    news_row.each do |news|
      news.save_if_not_exists
    end
  end
  
  #
  # DBに登録しているサイトの今日のニュースをRSSで取得して配列で返す
  # 
  # @return [Array] 
  def get_todays_news
    news_row = []

    # 各サイトのニュース記事をRSSを取得
    sites = Site.all
    sites.each do |site|
      rss = RSS::Parser.parse(site.feed_url, false)

      rss.items.each do |item|
        news = News.new
        news.title   = item.title
        news.url     = item.link
        news.site_id = site.id
        news_row.push(news)
      end
    end
    
    return news_row
  end
  
  #
  # 同じURLのデータが無ければDBに保存
  # 
  # @return [bool] 保存できればtrue
  def save_if_not_exists
    
    begin
      save
      #p '保存に成功しました'
    rescue => e
      #p '保存に失敗しました'
      #p e.message
      return false
    end
    
    return true 
  end
  
end
