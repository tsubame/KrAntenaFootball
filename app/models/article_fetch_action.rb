# -*- encoding: UTF-8 -*-
require 'open-uri'
require 'rss'
require 'assets/rss_fetcher'


# sitesテーブル内のサイトのRSSからブログ記事を取得し、articlesテーブルに保存する。
#
#
class ArticleFetchAction

  # 記事の配列
  attr_reader :articles
  
  def initialize
    @articles = []
  end
    
  # 処理実行 
  #
  #
  def exec
    fetch_articles_of_sites
    
    @articles.each do |article|
      article.save_if_not_exists
    end
  end

  # サイトの記事を取得
  #
  #
  def fetch_articles_of_sites
    sites = Site.all
    
    feed_urls = []
    sites.each do |site|
      feed_urls << site.feed_url
    end
    
    fetcher = RssFetcher.new
    rss_hash = fetcher.fetch_parallel(feed_urls)
    
    sites.each do |site|
      rss = rss_hash[site.feed_url]
      rss.items.each_with_index  do |item, i|
        article = Article.new
        article.title     = item.title 
        article.url       = item.link
        article.site_id   = site.id
        article.published = item.date
        @articles.push(article)
      end
    end
  end
  
  # はてブの人気エントリーを取得
  #
  # @return [Array] entries
  # entries = [
  #  {:title => "", :url => "", :count => 100}
  # ]
  def fetch_hatebu_entries
    url = "http://b.hatena.ne.jp/headline"
    uri = URI(url)
    content = uri.read().toutf8
    
    # 正規表現で検索
    pattern = %r|<li class="entrylist-unit category-economics|
    content.gsub(pattern) do ||
    end  
  end
  
end
