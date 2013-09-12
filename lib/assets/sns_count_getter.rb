# -*- encoding: utf-8 -*-
require 'open-uri'
require 'rss'
require 'fql'
require 'parallel'

# 特定のURLに対する、SNSでのシェア数を取得するクラス
# TwitterでのRT数（URLがつぶやかれた数）、
# Facebookでのシェア数のトータルカウント（いいね、シェア、コメントの合計）を取得する
#
# 
#
#== [使用ライブラリ]
#   fql
#   parallel
#
class SnsCountGetter
  # エラーメッセージ
  attr_reader   :error_message   #,:tw_counts_hash, :fb_counts_hash, :results
  # URLに対するTwitterRT数を格納するハッシュ。キーがURLで値がRT数 例：{"http://goo.gl" => 10, "URL2" => 3}
  attr_reader   :tw_counts_hash
  # URLに対するFacebookのシェア数を格納するハッシュ。構造は同上。
  attr_reader   :fb_counts_hash
  # URLに対するTwitter、Facebookのシェア数を格納するハッシュ。例：{"http://goo.gl" => { :fb_count => 10, :tw_count => 3}}
  attr_reader   :results
  
  # スレッドの最大数（テスト時には外から変更可能）
  attr_accessor :max_thread
  
  # スレッドの最大数のデフォルト値
  MAX_THREAD_DEFAULT = 10
  # TwitterAPIのURL
  TWITTER_API_URL = "http://urls.api.twitter.com/1/urls/count.json?url="
  
  def initialize
    @max_thread = MAX_THREAD_DEFAULT
    @error_message  = ""
    @tw_counts_hash = {}
    @fb_counts_hash = {}
    @results = {}
  end
    
  # 複数のURLに対するTwitter、Facebookでのシェア数を取得。
  #
  # マルチスレッドで並列処理。スレッドの最大数は@max_threadに従う。
  #
  # @param  [Array] urls
  def exec(urls)    
    req_count = 1
    urls_que = []
      
    urls.each_with_index do |url, i|
      urls_que << url
      if @max_thread <= urls_que.size || urls.size - 1 <= i
        puts "#{req_count}回目のアクセス"
        req_count += 1
        get_sns_counts_parallel(urls_que)
        urls_que = []
      end
    end
    
    return @results
  end

  # 複数のURLに対するTwitter、Facebookでのシェア数を取得し、
  # @tw_counts_hash、@fb_counts_hash、@resultsに保存する。
  #
  # マルチスレッドで並列処理。
  #
  # @param  [Array] urls
  def get_sns_counts_parallel(urls)
    ths = []
    urls.each do |url|
      ths << Thread.start do 
        fb_count = get_fb_count(url)
        tw_count = get_tw_count(url)
        @results[url] = {}  
        @results[url][:fb_count] = fb_count
        @results[url][:tw_count] = tw_count
      end
    end
    
    # 全てのスレッドの終了を待つ
    ths.each do |th|
      th.join      
    end
    
    return @results
  end
  
  # URLに対する、twitterのRT数を取得
  #
  # エラー時にはfalseを返す
  #
  # @param  [String]  url
  # @return [integer] count 
  def get_tw_count(url)
    #　文字列でなければ終了
    return false if url.is_a?(String) == false
    
    begin
      api_url = TWITTER_API_URL + CGI.escape(url)
      json_str = URI(api_url).read()
      hash = JSON.parse(json_str) 
      count = hash["count"]
    rescue => e
      @error_message += e.message
      Rails.logger.error(e.message)
      return false
    end  
      
    return count
  end
  
  # URLに対する、Facebookのシェア数のトータルカウントを取得
  # エラー時にはfalseを返す
  #
  # @param  [String]  url
  # @return [integer] count 
  def get_fb_count(url)
    #　文字列でなければ終了
    return false if url.is_a?(String) == false
    
    begin
      escaped_url = CGI.escape(url)
      query = %|SELECT total_count FROM link_stat WHERE url="#{escaped_url}"|
      response = Fql.execute(query)
#p response
      if response.size == 0 then
        return false
      end         
      count = response[0]["total_count"]        
    rescue => e
      @error_message += e.message
      Rails.logger.error(e.message)
      return false
    end  
    
    return count
  end
  
  # 処理結果にエラーがあればtrueを返す
  #
  # @return [bool] 
  def error?
    if 0 < @error_message.length
      return true
    else
      return false
    end  
  end
  
  
  
  # 並列処理でFbのトータルカウントを取得
  #
  # @param  [Array] urls
  # @return [Array] counts 
  def get_fb_count_parallel_limited(urls)    
    req_count = 1
    urls_que = []
      
    urls.each_with_index do |url, i|
      urls_que << url
      if @max_thread <= urls_que.size || urls.size - 1 <= i
        puts "#{req_count}回目のアクセス"
        req_count += 1
        get_fb_count_parallel(urls_que)
        urls_que = []
      end
    end
  end
  
  #
  #
  # @param  [Array] urls
  def get_fb_count_parallel(urls)
    ths = []
    urls.each do |url|
      ths << Thread.start(url) do |u|
        count = get_fb_count(u)
        @fb_counts_hash[url] = count
      end
    end
    
    ths.each do |th|
      th.join      
    end
  end
  
end