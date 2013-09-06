# -*- encoding: UTF-8 -*-
require 'open-uri'
require 'rss'

#
#
#
#
class ArticleCreateFromRankAction
  attr_reader :error_message, :articles
  attr_accessor :max_thread
  
  # エラーメッセージ
  @error_message  
  # 記事の配列
  @articles
  # スレッドの最大数（テスト時には外から変更する）
  @max_thread
  
  # スレッドの最大数のデフォルト値
  MAX_THREAD_DEFAULT = 20
  
  def initialize
    @articles = []
    @max_thread = MAX_THREAD_DEFAULT
  end
    
  # 処理実行 
  #
  #
  def exec
    # サイトを取得
    sites = Site.all
    feed_urls = []
    # サイトの件数ループ    
    sites.each do |site|
      feed_urls << site.feed_url
    end
    
    get_articles_by_multi_threads_limited(feed_urls)
    
    @articles.each do |article|
      article.save_if_not_exists
    end
  end
  
  # スレッドを使ってRSSから記事を取得する
  # スレッドの最大数は定数に従う
  # エラー時にはfalseを返す
  #
  # @param [Array] feed_urls
  # @return [Array] articles
  def get_articles_by_multi_threads_limited(feed_urls)
    req_urls = []
 
    req_count = 1
    feed_urls.each_with_index  do |url, i|
      req_urls << url
      if @max_thread <= req_urls.size || i == feed_urls.size - 1
        puts "#{req_count}回目のアクセス"
        req_count += 1
        get_articles_by_multi_threads(req_urls)
        req_urls = []
      end
    end
 
    return @articles
  end
  
  # スレッドを使ってRSSから記事を取得する
  # エラー時にはfalseを返す
  #
  # @param [Array] feed_urls
  # @return [Array] articles
  def get_articles_by_multi_threads(feed_urls)
    ths = []
    feed_urls.each do |feed_url|
      ths << Thread.start(feed_url) do |url|
        get_articles_to_array(url)
      end
    end
    
    ths.each do |th|
      th.join      
    end

    return @articles
  end
  
  # get_articles_from_rssの結果を@articlesに格納
  #
  # @param [String] feed_url
  # @return [Array] articles
  def get_articles_to_array(feed_url)
    articles = get_articles_from_rss(feed_url)
    #p articles
    @articles += articles
    
    return @articles
  end
  
  # RSSから記事を取得する
  # エラー時にはfalseを返す
  #
  # @param [String] feed_url
  # @return [Array] articles
  def get_articles_from_rss(feed_url)
    begin
      rss = RSS::Parser.parse(feed_url, false)
    rescue => e
      @error_message = 'RSSの取得に失敗しました' + e.message
      return false 
    end
    
    articles = []
    rss.items.each_with_index  do |item, i|
      article = Article.new
      article.title = item.title
      article.url   = item.link
      articles.push(article)
    end
    
    return articles
  end
  
end
