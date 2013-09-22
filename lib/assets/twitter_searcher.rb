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
  TWITTER_SEARCH_COUNT = 100
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
        #comments = search_twitter(q)
        comments = search_twitter_without_rt(q)
        @comments[q] = comments
      end
    end  
    
    # 全てのスレッドの終了を待つ
    ths.each do |th|
      th.join      
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
# スレッドの上限数は@max_threadに従う。
#
# @param  [Array] keywords
# @return [Hash]  @comments
def get_tw_comments_parallel_limited(entries)    
  req_count = 1
  entries_que = []
    
  entries.each_with_index do |entry, i|
    entries_que << entry
    if @max_thread <= entries_que.size || entries.size - 1 <= i
      puts "#{req_count}回目のアクセス"
      req_count += 1
      get_tw_comments_parallel(entries_que)
      entries_que = []
    end
  end
  
  return @comments
end



# Twitterでキーワード検索してCommentオブジェクトの配列で返す
# マルチスレッドで並列処理。 
#
# @param  [Array] entries
# @return [Hash]  @comments
#
#   @comments = {"検索ワード" => []}
#
def get_tw_comments_parallel(entries)
  ths = []
  #keywords.each do |q|
  entries.each do |entry|
    ths << Thread.start do 
      comments, rt_tweets = get_tw_comments_to_entry(entry)
      #comments = search_twitter_without_rt(q)
      @comments[entry.url] = comments
    end
  end  
  
  # 全てのスレッドの終了を待つ
  ths.each do |th|
    th.join      
  end
  
  return @comments
end  
  
  # 特定のエントリに対するツイッターコメントを取得する
  #
  # @param [Entry] entry 
  # @return [Array] comments
  # @return [Array] rt_tweets
  def get_tw_comments_to_entry(entry)
    client = Twitter::Client.new
    rt_tweets = []
    comments  = []
    # タイトルを分割
    split_titles = split_title(entry.title)

    begin
      client.search(entry.url, :count => @twitter_search_count, :result_type => "recent", :since_id => 0).results.reverse.map do |status|
        if status.retweeted_status
          rt_tweets << status
          next
        elsif status.text[ /^RT[：:\s@]/ ]
          next
        end
                
        comment = tweet_to_comment(status, entry.id)
        comment.text = pickup_comment_from_tweet(comment.text, entry.title, split_titles)
        #comment.text = remove_url_and_title_from_tweet(comment.text, entry)
        if comment.text != false
          comments << comment
        end
      end
    rescue => e
      puts @error_message += "get_tw_comments_to_entry #{e}"
      Rails.logger.error(e.message)
      return false
    end
    
    comments = remove_multiple_tweet(comments)
    
    return comments, rt_tweets
  end
  
  # テキストが重複するコメントは削除
  #
  def remove_multiple_tweet(tweets)
    #tweets
    hashes = []
    # ツイートの件数ループ
    tweets.each do |tweet|
      text = tweet.text
      # ハッシュの配列に保存 hashes = [ {"text" => "", "count" = 1} ]
      is_saved = false
      hashes.each do |hash|
        if hash[:text] == text
          hash[:count] += 1
          is_saved = true
          break
        end
      end
      
      if is_saved == false
        hash = { :text => text, :count => 1, :tweet => tweet }
        hashes << hash
      end
    end
    
    comment_tweets = []
    no_comment_texts = []
    hashes.each do |hash|
      if hash[:count] == 1
        comment_tweets << hash[:tweet]
      else
        no_comment_texts << hash[:text]
      end
    end
    no_comment_texts = no_comment_texts.sort do |a, b|
      b.size <=> a.size
    end

    comment_tweets.each_with_index do |tweet, i|
      no_comment_texts.each do |text|
        comment_tweets[i][:text] = tweet[:text].sub(text, "")
      end
    end  
    p no_comment_texts
    return comment_tweets
  end
  
  # ツイートのテキストからコメント以外を省く
  # URL、サイト名、タイトル名など
  #
  def remove_url_and_title_from_tweet(text, entry)
    #　文字列でなければ終了
    return false if text.is_a?(String) == false
    
    begin
      title_last = entry.title[/[　\s：:][^　\s:：]+$/]
      if title_last != nil
        title_last = title_last.gsub(/[　\s]/, "")
        text = text.gsub(title_last, "")
      end
      title_head = entry.title[/(.+)[　\s：:][^　\s：:]+$/, 1]
      if title_head != nil
        title_head = title_head.gsub(/[　\s]/, "")
        text = text.gsub(title_head, "")
      end
      title = entry.title
      title = title.gsub(/[　\s]/, "")
      text = text.gsub(/[　\s]/, "")
    
      text = text.gsub(title, "")

      text = text.gsub(URI.regexp(), "")
      text = text.strip
      
      text = text.sub(/^[\d]+RT[:：\s]+/, "")
      text = text.sub(/RT[　\s:："]+.*$/im, "")
      text = text.sub(/RT[　\s:："]*@.*$/im, "")
      text = text.sub(/@[\w]+.*$/im, "")
      text = text.gsub(/\[[^\]]*\]/, "")
      text = text.gsub(/#[^\s　]+/, "")
      text = text.gsub(/[”“]/, "")
      text = text.sub(/[　\s]+@[\w]+さんから/, "")
      text = text.gsub(/[　\n]+/, "")
      text = text.gsub(/[　\s]+\-/, "")
      text = text.gsub(/\-[　\s]+/, "")
      text = text.sub(/RT[\s　]*$/, "")
      text = text.sub(/[\(（].*[\)）][\s　]*$/, "")
      text = text.sub(/["”“:：@\/『』]+$/, "")
      text = text.gsub(/[:：]/, "")
      text = text.sub(/^[\(（].*$/, "")
      text = text.sub(/^【.*$/, "")
      text = text.sub(/^[\w\s|｜\-]+$/, "")
      text = text.sub(/^.*(はてブ|はてなブックマーク).*$/, "")
      text = text.sub(/他[\d]+コメント/, "")
      text = text.sub(/[\-\s\/]+$/, "")
      text = text.sub(%r|メモ[\s/]*$|im, "")
      text = text.sub(/^ブログ更新.*/m, "") 
    rescue => e
      puts @error_message += " remove_url_and_title_from_tweet " + e.message
      Rails.logger.error(e.message)
      return text
    end

    
    return text
  end
  
  
# クライアントがhatenaの時も省いていいかも  
  
  # ツイートから投稿者のコメントを抜き出して返す
  # コメントのないツイートならfalse
  #
  # @param [String] text
  # @param [Array]  split_titles
  # @param [String] site_title
  def pickup_comment_from_tweet (text, entry_title, split_titles = nil, site_title = nil)
    return false if text.is_a?(String) == false || entry_title.is_a?(String) == false
    
    # URLを削除
    text = text.gsub(URI.regexp(), "")
    # ハッシュタグ削除
    text = text.gsub(/#[^\s　]+/, "")
    # “”を削除
    text = text.gsub(/[”“]/, "")
    # タイトル削除
    text = text.gsub(entry_title, "")
    # タイトルを分割して取得
    if split_titles == nil
      split_titles = split_title(entry_title)
    end    
    split_titles.each do |title|
      text = text.gsub(title, "")
    end
    
    # RT〜を削除
    text = text.sub(/RT[　\s:："]+.*$/im, "")
    # 他◯コメントを削除
    text = text.sub(/他[\d]+コメント/, "")
    # メンションツイートは削除
    text = text.sub(/^@[\w]+.*$/, "")
    # @〜〜からを削除
    text = text.sub(/[　\s]+@[\w]+.*から/, "")
    # via @〜〜を削除
    text = text.sub(/via[　\s]+@[\w]+/, "")
    # [〜]を削除
    text = text.sub(/(\[.*\]|『[\s　]*』|「[\s　]*」)/, "")
    # &~;を削除
    text = text.sub(/&[\w]+;/, "")
    
    # はてなブックマーク、はてブ、[B!]が入ってるツイートも削除
    text = text.sub(/^.*(はてブ|はてなブックマーク|\[B!\]).*$/, "")
    # 【◯RT】が入ってるツイートも削除
    text = text.sub(/^.*【[\d]*RT】.*$/, "")
    # 英語だけが残ったなら削除
    text = text.sub(/^[\w\s\.,…@\-"]+$/, "")
    
    # 両端の空白削除
    text = text.strip
    
    # 末尾の / ／:：|｜-を削除            
    text = text.sub(/[　\-\s\/／\|｜：:@…\.）\)（\(＞>＜<→"]+$/, "")
    # 先頭の / ／:：|｜-を削除         
    text = text.sub(/^[　\-\s\/／\|｜：:@…\.）\)（\(＞>＜<→"]+/, "")
    
    # 【】がツイートの先頭に来ている場合は全て削除
    unless entry_title =~ /^【/
      text = text.sub(/^【.*$/, "")
    end
    
    if text.length == 0
      return false
    end
    
    return text
  end
  
  # タイトルを空白、：-で分割
  # titlesは文字列の長い順に並び変え
  #
  def split_title(title)
    # タイトル分割
    splits = title.split(/[　\s:：\-｜\|]+/)
    splits << title
    # 文字列の長い順に並び変え
    titles = splits.sort do |a, b|
      b.size <=> a.size
    end   
    
    return titles
  end
  
  
  
  
  # 
  #
  #
  def tweet_to_comment(tweet_status, entry_id = nil)
    comment = Comment.new     
    comment.text      = tweet_status.text
    comment.url       = "http://twitter.com/#{tweet_status.from_user}/status/#{tweet_status.id}"
    comment.icon_url  = tweet_status.user.profile_image_url
    comment.published = tweet_status.created_at
    comment.user_account = "@" + tweet_status.from_user
    
    if entry_id != nil
      comment.entry_id = entry_id
    end

    return comment 
  end  
  
  # Twitterでキーワード検索してCommentオブジェクトの配列で返す
  # 公式RTのツイートは無視する
  #
  # @param  [String] q
  # @return [Array] comments
  def search_twitter_without_rt(q)
    client = Twitter::Client.new
    comments = []
    begin
      client.search(q, :count => @twitter_search_count, :result_type => "recent", :since_id => 0).results.reverse.map do |status|
        if status.retweeted_status
          next
        elsif status.text[ /^RT[：:\s@]/ ]
          next
        end
        
        comment = Comment.new     
        comment.text      = status.text
        comment.url       = "http://twitter.com/#{status.from_user}/status/#{status.id}"
        comment.icon_url  = status.user.profile_image_url
        comment.published = status.created_at
        comment.user_account = "@" + status.from_user  
        comments << comment
      end
    rescue => e
      puts @error_message += e.message
      Rails.logger.error(e.message)
      return false
    end
    
    comments, no_comments = pickup_comment_tweets(comments)
    
    return comments
  end
  
  # URLと記事タイトルだけのツイート、
  # それ以外のコメント付きのツイートに振り分ける
  #
  # @param [Array] comments
  # @return [Array] comment_tweets
  # @return [Array] no_comment_tweets
  def pickup_comment_tweets(tweets)
    hashes = []
    # ツイートの件数ループ
    tweets.each do |tweet|
      # URLなど省く
      text = tweet.text.gsub(URI.regexp(), "")
      text = text.gsub(/\[[^\]]*\]/, "")
      text = text.gsub(/[　\n]+/, "")
      text = text.gsub(/#[\w]+/, "")
      text = text.gsub(/[”“]/, "")
      text = text.gsub(/@[\w]+さんから/, "")
      text = text.sub(/^[\d]+RT[:：\s]+/, "")
      text = text.strip
      tweet.text = text
      # ハッシュの配列に保存 hashes = [ {"text" => "", "count" = 1} ]
      is_saved = false
      hashes.each do |hash|
        if hash[:text] == text
          hash[:count] += 1
          is_saved = true     
          break
        end
      end
      
      if is_saved == false
        hash = { :text => text, :count => 1, :tweet => tweet }
        hashes << hash
      end
      # 配列に保存したものと全く同じツイートは省く
    end  

    comment_tweets = []
    no_comment_tweets = []
    hashes.each do |hash|
      if hash[:count] == 1
        comment_tweets << hash[:tweet]
      else
        no_comment_tweets << hash[:tweet]
        no_comment_texts = hash[:text]
      end
    end    
    
    return comment_tweets, no_comment_tweets 
  end
  
end