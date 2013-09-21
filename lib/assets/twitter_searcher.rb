# -*- encoding: utf-8 -*-
require 'open-uri'
require 'kconv'
require 'nokogiri'

# ツイッターからキーワード検索を行い、Commentオブジェクトの配列で返す
# 
#
class TwitterSearcher
 
  # エラーメッセージ
  attr_reader   :error_message   
  # スレッドの最大数（テスト時には外から変更可能）
  attr_accessor :max_thread
  # 1件のキーワード検索で取得するコメント件数（テスト時には外から変更可能）
  attr_accessor :twitter_search_count
  
  # 1件のキーワード検索で取得するコメント件数（デフォルト値）
  TWITTER_SEARCH_COUNT = 30
  # スレッドの最大数（デフォルト値）
  MAX_THREAD_DEFAULT = 10
  
  def initialize
    @error_message = ""
    @max_thread    = MAX_THREAD_DEFAULT
    @twitter_search_count = TWITTER_SEARCH_COUNT
    @comments = {}
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
  
  # Twitterでキーワード検索してCommentオブジェクトの配列で返す
  # マルチスレッドで並列処理。
  # スレッドの上限数は@max_threadに従う。
  #
  # @param  [Array] keywords
  # @return [Hash]  @comments
  def search_twitter_parallel_limited(keywords)    
    req_count = 1
    keywords_que = []
      
    keywords.each_with_index do |url, i|
      keywords_que << url
      if @max_thread <= keywords_que.size || keywords.size - 1 <= i
        puts "#{req_count}回目のアクセス"
        req_count += 1
        search_twitter_parallel(keywords_que)
        keywords_que = []
      end
    end
    
    return @comments
  end
  
  # Twitterでキーワード検索してCommentオブジェクトの配列で返す
  #
  # @param  [String] q
  # @return [Array] comments
  def search_twitter(q)
    client = Twitter::Client.new
    comments = []
    begin
      client.search(q, :count => @twitter_search_count, :result_type => "recent", :since_id => 0).results.reverse.map do |status|
          comment = Comment.new        
          comment.text      = status.text
          comment.url       = "http://twitter.com/#{status.from_user}/status/#{status.id}"
          comment.icon_url  = status.user.profile_image_url
          comment.published = status.created_at
          comment.user_account = "@" + status.from_user  
          comments << comment
      end
    rescue => e
      @error_message += e.message
      Rails.logger.error(e.message)
      return false
    end
    
    return comments
  end
  
  # Twitterでキーワード検索してCommentオブジェクトの配列で返す
  # マルチスレッドで並列処理。 
  #
  # @param  [Array] keywords
  # @return [Hash]  @comments
  #
  #   @comments = {"検索ワード" => []}
  #
  def search_twitter_parallel(keywords)
    ths = []
    keywords.each do |q|
      ths << Thread.start do 
        comments = search_twitter(q)
        @comments[q] = comments
      end
    end  
    
    # 全てのスレッドの終了を待つ
    ths.each do |th|
      th.join      
    end
    
    return @comments
  end  

end