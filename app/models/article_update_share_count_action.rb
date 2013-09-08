# -*- encoding: UTF-8 -*-
require 'open-uri'
require 'rss'
require 'assets/social_share_count_getter'

# articlesテーブル内の最近の記事の
# ソーシャルサイトでのシェア数を取得し、テーブル内のデータを更新
#
class ArticleUpdateShareCountAction
  #attr_accessor 
  
  #
  @max_update_hour
  #
  @max_update_count
  
  # この時間より前の記事のシェア数は取得しない 24 → 24時間以内の記事のみが対象
  MAX_UPDATE_HOUR  = 24
  # この件数より前の記事のシェア数は取得しない 180 → 最近180件の記事のみが対象
  MAX_UPDATE_COUNT = 180
  
  def initialize
    @getter = SocialShareCountGetter.new
    @max_update_hour  = MAX_UPDATE_HOUR
    @max_update_count = MAX_UPDATE_COUNT
  end
    
  # 処理実行 
  #
  def exec
    model = Article.new
    articles = model.select_recent_data_limited(24, 100)

    # 記事の件数
    urls = []
    articles.each do |article|
      urls << article.url
    end
    puts "#{urls.size}件の記事"
    @getter.get_fb_total_count_parallel(urls)
    fb_results = @getter.fb_counts_hash
    
    articles.each do |article|
      article.fb_share = fb_results[article.url]
    end
    
    @getter.get_tw_rt_count_parallel(urls)
    tw_results = @getter.tw_counts_hash
    
    articles.each do |article|
      article.tw_retweet = tw_results[article.url]
      puts "#{article.url}: #{article.tw_retweet}"
    end
    
    articles.each do |article|
      article.save
    end
  end

end
