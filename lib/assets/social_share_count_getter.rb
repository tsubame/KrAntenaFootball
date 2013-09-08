# -*- encoding: utf-8 -*-
require 'open-uri'
require 'rss'
require 'fql'
require 'parallel'

# 特定のURLに対する、SNSでのシェア数を取得するクラス
# TwitterでのRT数（URLがつぶやかれた数）、
# Facebookでのシェア数のトータルカウント（いいね、シェア、コメントの合計）を取得する
#
#== [使用ライブラリ]
#   fql
#   parallel
#
class SocialShareCountGetter
  attr_reader :error_message, :tw_counts_hash, :fb_counts_hash
  attr_accessor :max_thread
  
  # エラーメッセージ
  @error_message  
  # スレッドの最大数（テスト時には外から変更する）
  @max_thread
  # スレッドの最大数のデフォルト値
  MAX_THREAD_DEFAULT = 20
  #
  TWITTER_API_URL = "http://urls.api.twitter.com/1/urls/count.json?url="
  
  @tw_counts_hash
  @fb_counts_hash
  
  def initialize
    @error_message = ""
    @max_thread = MAX_THREAD_DEFAULT
    @tw_counts_hash = {}
    @fb_counts_hash = {}
  end
  
  # エラーメッセージがあればtrueを返す
  #
  # @return [bool] 
  def error?
    if 0 < @error_message.length
      return true
    else
      return false
    end  
  end
  
  # URLに対する、twitterのRT数を取得
  #
  # エラー時にはfalseを返す
  #
  # @param  [String]  url
  # @return [integer] count 
  def get_tw_rt_count(url)
    #　文字列でなければ終了
    return false if url.is_a?(String) == false
    
    begin
      api_url = TWITTER_API_URL + CGI.escape(url)
      json_str = URI(api_url).read()
      #json_str = uri.read()
      hash = JSON.parse(json_str) 
      count = hash["count"]
    rescue => e
      @error_message += e.message
      return false
    end  
      
    return count
  end

  # URLに対する、Facebookのシェア数のトータルカウントを取得
  # エラー時にはfalseを返す
  #
  # @param  [String]  url
  # @return [integer] count 
  def get_fb_total_count(url)
    #　文字列でなければ終了
    return false if url.is_a?(String) == false
    
    begin
      escaped_url = CGI.escape(url)
      query = %|SELECT total_count FROM link_stat WHERE url="#{escaped_url}"|
      response = Fql.execute(query)
      count = response[0]["total_count"]        
    rescue => e
      @error_message += e.message
      return false
    end  
    
    return count
  end
    
  # 並列処理でTwitterのRT数を取得
  #
  # @param  [Array] urls
  # @return [Array] counts 
  def get_tw_rt_count_parallel(urls)  
    results = Parallel.map(urls, :in_threads => @max_thread) do |url|
      count = get_tw_rt_count(url)      
      #puts "#{count} RT: #{url}"      
      @tw_counts_hash[url] = count
      count
    end
    
    return results
  end
  

  
  # 並列処理でFbのトータルカウントを取得
  #
  # @param  [Array] urls
  # @return [Array] counts 
  def get_fb_total_count_parallel(urls)
    results = Parallel.map(urls, :in_threads => @max_thread) do |url|
      count = get_fb_total_count(url)      
      #puts "#{count} share: #{url}"
      @fb_counts_hash[url] = count      
      count
    end
    
    return results
  end
  
  
end