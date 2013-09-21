# -*- encoding: utf-8 -*-
require 'open-uri'
require 'kconv'
require 'rss'

# RSSを取得するクラス。
# fetch_parallelで複数件のRSSを並列に取得できる。
# 
# 
#
class RssFetcher
  


  # エラーメッセージ
  attr_reader   :error_message
  # スレッドの最大数（テスト時には外から変更する）  
  attr_accessor :max_thread
  
  MAX_THREAD_DEFAULT = 30
  
  def initialize
    @error_message = ""
    @max_thread = MAX_THREAD_DEFAULT
    @rss_hash = {}
  end
    
  # 処理内容にエラーがあればtrue
  #
  # @return [Bool] 
  def error?
    if 0 < @error_message.length
      return true
    else
      return false
    end
  end
  
  # スレッド数の上限を指定して複数のサイトのRSS記事を取得
  # スレッドの最大数は@max_thread
  #
  # @param  [Array] feed_urls フィードURLの配列
  # @return [Hash] @rss_hash
  def fetch_parallel(feed_urls)
    req_count = 1
    urls_que = []
      
    feed_urls.each_with_index do |feed_url, i|
      urls_que << feed_url
      if @max_thread <= urls_que.size || feed_urls.size - 1 <= i
        puts "#{req_count}回目のアクセス"
        req_count += 1
        fetch_parallel_with_thread(urls_que)
        urls_que = []
      end
    end
    
    return @rss_hash
  end
  
  # スレッドを使って複数のサイトのRSS記事を取得し、@rss_hashに格納する
  # 
  # @rss_hash = {"http://~（フィードURL）" => RSS}
  # @param  [Array] feed_urls フィードURLの配列
  def fetch_parallel_with_thread(feed_urls)
    ths = []
    feed_urls.each do |feed_url|
      ths << Thread.start(feed_url) do |u|
        rss = fetch(u)
        @rss_hash[u] = rss
      end
    end
    
    ths.each do |th|
      th.join      
    end
  end
  
  # 単一サイトのRSSを読み込む
  # エラー時にはfalseを返す
  #
  # @param  [String] feed_url
  # @return [RSS] rss
  def fetch(feed_url)
    begin
      puts "RSS取得中：#{feed_url}"
      rss = RSS::Parser.parse(feed_url, false)
    rescue => e
      @error_message = 'RSSの取得に失敗しました' + e.message
      return false 
    end
    
    return rss
  end

end