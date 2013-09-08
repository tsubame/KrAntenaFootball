# -*- encoding: UTF-8 -*-
require 'open-uri'
require 'rss'

# sitesテーブル内のサイトのRSSからブログ記事を取得し、articlesテーブルに保存する。
#
#
class ArticleCreateFromRssAction
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
    sites = Site.all    
    get_articles_parallel_limited(sites)
    
    @articles.each do |article|
      article.save_if_not_exists
    end
  end
  
  # スレッド数の上限を指定して複数のサイトのRSS記事を取得
  # スレッドの最大数は@max_thread
  #
  # @param  [Array] sites Siteの配列
  def get_articles_parallel_limited(sites)
    req_count = 1
    sites_que = []
      
    sites.each_with_index do |site, i|
      sites_que << site
      if @max_thread <= sites_que.size || sites.size - 1 <= i
        puts "#{req_count}回目のアクセス"
        req_count += 1
        get_articles_parallel(sites_que)
        sites_que = []
      end
    end
  end
  
  # スレッドを使って複数のサイトのRSS記事を取得
  #
  # @param  [Array] sites Siteの配列
  def get_articles_parallel(sites)
    ths = []
    sites.each do |site|
      ths << Thread.start(site) do |s|
        get_articles_from_site(s)
      end
    end
    
    ths.each do |th|
      th.join      
    end
  end
  
  # 単一サイトのRSSを読み込んで記事を取得し、@articlesに格納
  #
  # @param  [Site]  site
  def get_articles_from_site(site)
    rss = get_articles_from_rss(site.feed_url)
    
    #articles = []
    rss.items.each_with_index  do |item, i|
      article = Article.new
      article.title   = item.title
      article.url     = item.link
      article.site_id = site.id
      article.published_at = item.date
      @articles.push(article)
    end
    
    #@articles += articles
  end
  
  # 単一サイトのRSSを読み込む
  # エラー時にはfalseを返す
  #
  # @param  [String] feed_url
  # @return [RSS] rss
  def get_articles_from_rss(feed_url)
    begin
      rss = RSS::Parser.parse(feed_url, false)
    rescue => e
      @error_message = 'RSSの取得に失敗しました' + e.message
      return false 
    end
    
    return rss
  end
  
end
