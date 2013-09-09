# -*- encoding: UTF-8 -*-
require 'open-uri'
require 'rss'
require 'assets/sns_count_getter'

# articlesテーブル内の最近の記事の
# ソーシャルサイトでのシェア数を取得し、テーブル内のデータを更新
#
class ArticleUpdateSnsCountAction
  
  # この時間より前の記事のシェア数は取得しない 24 → 24時間以内の記事のみが対象
  MAX_UPDATE_HOUR  = 24
  # この件数より前の記事のシェア数は取得しない 180 → 最近180件の記事のみが対象
  MAX_UPDATE_COUNT = 180
  
  def initialize
    @getter = SnsCountGetter.new
    @update_hour  = MAX_UPDATE_HOUR
    @update_count = MAX_UPDATE_COUNT
  end
    
  # 処理実行 
  #
  def exec
    model = Article.new
    # 最近の記事を取得してURLを配列に格納
    articles = model.select_recent_data_limited(@update_hour, @update_count)
    puts "#{articles.size}件の記事"
    urls = []
    articles.each do |article|
      urls << article.url
    end
    # SNSのシェア数を取得
    results = @getter.exec(urls)
        
    articles.each do |article|
      article.tw_count = results[article.url][:tw_count]
      article.fb_count = results[article.url][:fb_count]
    end
    
    articles.each do |article|
      article.save
    end
  end

end
