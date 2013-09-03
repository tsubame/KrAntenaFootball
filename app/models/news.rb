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
  
end
