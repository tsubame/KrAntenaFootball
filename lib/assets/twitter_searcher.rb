# -*- encoding: utf-8 -*-
require 'open-uri'
require 'kconv'
require 'nokogiri'

# 特定のエントリ（記事）に対するツイッターでのコメントを取得し、Commentオブジェクトの配列で返すモジュール。
#
#== 説明
# エントリのURLでツイッター検索を行い、
# 検索結果のツイートからエントリのタイトルやURL、ハッシュタグなどを削除し、
# 残った文字列をコメントとみなしてComment.textに格納する。
# 取得した結果はハッシュの配列commentsで返す。
#
#== 依存クラス
#   models::Entry
#   models::Comment
#   Twitter(Ruby gems)
#
#== 使い方
#   entries  = Entry.all
#   searcher = TwitterSearcher.new
#   comments = searcher.exec
#
#== 返り値commentsのデータ形式
#   comments = {"エントリのURL" => [Comment, Comment], "エントリのURL" => ...}
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
    
  # 処理を実行
  #
  # @param  [Array] entries
  # @return [Hash]  comments
  def exec(entries)    
    comments = get_tw_comments_parallel_limited(entries)
    
    return comments
  end
  
  # エントリのURLでTwitter検索を行い、Commentオブジェクトの配列で返す。
  # スレッドの上限を指定したマルチスレッド。
  # スレッドの上限数は@max_threadに従う。
  #
  # @param  [Array] entries
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

  # エントリのURLでTwitter検索を行い、Commentオブジェクトの配列で返す
  # 上限なしのマルチスレッド。 
  #
  # @param  [Array] entries
  # @return [Hash]  @comments
  def get_tw_comments_parallel(entries)
    ths = []
  
    entries.each do |entry|
      ths << Thread.start do 
        comments = get_tw_comments_to_entry(entry)
        @comments[entry.url] = comments
      end
    end  
    
    # 全てのスレッドの終了を待つ
    ths.each do |th|
      th.join      
    end
    
    return @comments
  end  
  
  # 特定のエントリに対するツイッターコメントを取得する。
  #
  # @param  [Entry] entry 
  # @return [Array] comments
  def get_tw_comments_to_entry(entry)    
    # ツイート検索
    tweets   = search_tweet(entry)
    # コメント付きのツイートのみを取得
    comments = pickup_with_comment_tweets(tweets, entry)   
    
    return comments
  end
  
  # ツイッターの検索結果をツイート（Twitter::Status）の配列で返す。
  # ツイートがリツイートなら省く。
  #（他のツイートをリツイートしたものなら配列に格納しない）
  #
  # @param  [Entry] entry 
  # @return [Array] tweets
  def search_tweet(entry)      
    begin
      # エントリのURLでツイッター検索  
      client = Twitter::Client.new
      result = client.search(entry.url, :count => @twitter_search_count, :result_type => "recent", :since_id => 0).results.reverse
    rescue => e
      puts @error_message += " #get_tw_comments_to_entry #{e}"
      Rails.logger.error(e.message)
      return false
    end
    
    tweets = []
    # リツイート以外のツイートを配列に入れる
    result.map do |status|
      if status.retweeted_status
          next
      end      
      tweets << status
    end

    return tweets
  end
    
  # ツイートの配列を受け取って、コメント付きのツイートのみをCommentオブジェクトの配列で返す
  #
  # @param  [Array] tweets
  # @param  [Entry] entry
  # @return [Array] comments
  def pickup_with_comment_tweets(tweets, entry) 
    comments = []
    # エントリのタイトルを分割しておく
    split_titles = split_title(entry.title)

    tweets.each do |tweet|
    
      # ツイートをCommentオブジェクトに直す
      comment = tweet_to_comment(tweet, entry.id)
      # ツイートの本文からURLや記事タイトルを除いたコメントのみを取り出す
      comment.text = pickup_comment_from_tweet(comment.text, entry.title, split_titles)
      # エントリの本文と一致する記事は削除
      comment.text = is_tweet_not_entry_text?(comment.text, entry.description)
      
      if comment.text != false
        comments << comment
      end
    end
    
    # 同じ内容のツイートを削除
    comments = remove_multiple_tweet(comments)
    
    return comments
  end
  
  # ツイートの検索結果をCommentオブジェクトの形に直す。
  #
  # @param  [Twitter::Status] tweet_status
  # @return [Comment] comment
  def tweet_to_comment(tweet_status, entry_id = nil)
    comment = Comment.new     
    comment.text      = tweet_status.text
    comment.url       = "http://twitter.com/#{tweet_status.from_user}/status/#{tweet_status.id}"
    comment.icon_url  = tweet_status.user.profile_image_url
    comment.published = tweet_status.created_at
    comment.criant    = tweet_status.source
    comment.user_account  = "@" + tweet_status.from_user
    comment.original_text = tweet_status.text
  
    if entry_id != nil
      comment.entry_id = entry_id
    end
  
    return comment 
  end  
  
  # ツイートからURLやエントリタイトル、ハッシュタグなどを削除し、投稿者のコメントのみを抜き出して返す。
  # コメントのないツイートならfalse。
  #
  # @param [String] text
  # @parm  [String] entry_title
  # @param [Array]  split_titles
  # @param [String] site_title
  # @return [String] text
  def pickup_comment_from_tweet(text, entry_title, split_titles = nil, site_title = nil)
    # コメントとみなす最小の文字数
    min_text_length = 5
    # 引数が文字列でなければfalseを返す
    return false if text.is_a?(String) == false || entry_title.is_a?(String) == false
    
    # URL、タイトルなどを削除
    text = remove_url_and_others(text, entry_title, split_titles)   
    # その他のNGワードを削除
    text = remove_ng_word_from_tweet(text)
    # その他の英語、記号などを削除
    text = remove_no_use_chars(text)
    
    # 【】がツイートの先頭に来ている場合は全て削除
    text = remove_head_kakko(text, entry_title)
    
    if text.length < min_text_length
      return false
    end
    
    return text
  end
  
  # URL、ハッシュタグ、タイトルなどを削除
  #
  # @param [String] text
  # @return [String] text
  def remove_url_and_others(text, entry_title, split_titles)
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
   
   return text
  end
  
  # ツイートからNGワードを削除する
  #  
  # @param [String] text
  # @return [String] text
  def remove_ng_word_from_tweet(text)
   # RT〜を削除
   text = text.sub(/(RT|QT)[　\s:："@]+.*$/im, "")
   # .@~~を削除
   text = text.sub(/^[\.]*@[\w]+$/m, "")
   # 他◯コメントを削除
   text = text.sub(/他[\d]+コメント/, "")
   # メンションツイートは削除
   text = text.sub(/^@[\w]+.*$/, "")
   # @〜〜からを削除
   text = text.sub(/[　\s]+@[\w]+.*から/, "")
   # via @〜〜を削除
   text = text.sub(/via[　\s]+@[\w]+/, "")
   # [〜]を削除
   text = text.gsub(/(\[[\s.]*\]|『[\s　]*』|「[\s　]*」)/m, "")    
   # はてなブックマーク、はてブ、[B!]、いいね！、ブログ更新が入ってるツイートも削除
   text = text.sub(/^.*(はてブ|はてぶ|はてなブックマーク|いいね！|ブログ更新|\[B!\]).*$/, "")
   # 【◯RT】が入ってるツイートも削除
   text = text.sub(/^.*【[\d]*RT】.*$/, "")
   # Reading...を削除
   text = text.sub(/Reading[\.…]*/mi, "")
   # (1:20)(50users)[titles]を削除
   text = text.sub(/\([\d:]+\)/, "")
   text = text.sub(/[\(][\w\s]+[\)]/, "")
   text = text.sub(/\[[\w\s]+\]/, "")
   
   return text
  end
  
  # 英語や記号、空白を削除
  #
  # @param [String] text
  # @return [String] text
  def remove_no_use_chars(text)
    # 英語や記号だけが残ったなら削除
    text = text.sub(/^[\w\s\/\.\|\(\)\[\]&　,／｜：:…@（＞>＜<→"”“]+$/m, "")   
    # 両端の空白削除
    text = text.strip
    # [〜]を削除
    text = text.gsub(/^\[.*\]$/, "")
    # &~~;を削除
    text = text.gsub(/&[\w]+;/, "")   
    # 末尾の / ／:：|｜-を削除        
    text = text.sub(/[　\-\s\/／\|｜：:…@\.（\(＞>＜<→"]+$/, "")
    # 先頭の / ／:：|｜-を削除       
    text = text.sub(/^[　\-\s\/／\|｜：:@…\.）\)＞>＜<→"]+/, "")
    text = text.sub(/^[\s　]*[\(（][\s　]+/, "")
    
    return text
  end
  
  # 【】がツイートの先頭に来ている場合は全て削除
  #
  # @param [String] text
  # @parm  [String] entry_title
  # @return [String] text
  def remove_head_kakko(text, entry_title)
   if text[0, 1] == "【"
     if entry_title[0, 1] == "【"
       title_head = entry_title[/^(【.*】)/, 1]
       if text[0, title_head.length] != title_head
         text = ""
       end
     else
       text = ""
     end      
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
  
  
  
  
  
  # テキストが重複するコメントは削除し、
  # それ以外のツイートからも重複したコメントの文字列を削除する。
  #
  # @param  [Array] tweets
  # @return [Array] no_multi_tweets
  def remove_multiple_tweet(tweets)
    # 重複するツイート、重複してないツイートに振り分ける
    no_multi_tweets, multiple_tweets = devide_multi_and_no_multi_tweets(tweets)
    multiple_texts  = []
    # 重複したツイートの本文のみを取り出す
    multiple_texts = multiple_tweets.map do |tweet|
      tweet[:text]
    end

    # 重複したツイートを文字数の大きい順に並び変え
    multiple_texts = multiple_texts.sort do |a, b|
      b.size <=> a.size
    end
    # 重複したツイートの本文をそれ以外のツイートから削除
    no_multi_tweets.each_with_index do |tweet, i|
      multiple_texts.each do |text|
        no_multi_tweets[i][:text] = tweet[:text].sub(text, "")
        # 空白などを削除
        no_multi_tweets[i][:text] = remove_no_use_chars(no_multi_tweets[i][:text])
      end
    end
     
    multiple_texts.each do |text|
      puts "--重複テキスト #{text}"
    end
    
    return no_multi_tweets
  end
  
  # 複数のツイートを受取り、本文が重複するツイートと重複していないツイートに振り分ける。
  # 
  # @param  [Array] tweets
  # @return [Array] no_multi_tweets
  # @return [Array] multiple_tweets
  def devide_multi_and_no_multi_tweets(tweets)
    no_multi_tweets = []
    multiple_tweets = []
      
    # 内容が同じテキストの出現回数をハッシュの配列に取得する
    multi_count_hashes = get_multiple_count_of_tweets_to_hash(tweets)
    # 重複したツイート、重複してないツイートに振り分ける
    multi_count_hashes.each do |hash|
      if hash[:count] == 1
        no_multi_tweets << hash[:tweet]
      else
        multiple_tweets << hash[:tweet]
      end
    end
    
    return no_multi_tweets, multiple_tweets 
  end
  
  # 複数のツイートを受取り、本文が同じテキストの出現回数をハッシュの配列に記録する。
  # 重複するツイートは2以上、重複していなければ1。
  #
  # @param [Array] tweets
  # @return [Array] multi_count_hashes
  #
  #   multi_count_hashes = [ {"text" => "", "count" = 1} ]
  #
  def get_multiple_count_of_tweets_to_hash(tweets)
    multi_count_hashes = []
    
    tweets.each do |tweet|
      is_saved = false
      multi_count_hashes.each do |multi_tweet|
        if multi_tweet[:text] == tweet.text
          multi_tweet[:count] += 1
          is_saved = true
          break
        end
      end
      
      if is_saved == false
        multi_tweet = { :text => tweet.text, :count => 1, :tweet => tweet }
        multi_count_hashes << multi_tweet
      end
    end
    
    return multi_count_hashes
  end
  
  # ツイートの先頭数文字がエントリの本文とマッチしていたらfalseを返す。
  # 一致していなければそのままテキストをかえす
  #
  def is_tweet_not_entry_text?(tweet_text, entry_text)
    return tweet_text if entry_text.is_a?(String) == false
    return false if tweet_text.is_a?(String) == false
        
    part_tweet = tweet_text[0, 10]
    if entry_text.include?(part_tweet)
      return false
    end
    
    return tweet_text
  end  
  

  
  
 
  


 
  
  
def get_comments_from_search_result_org(entry)
  comments = []
  tiny_url = nil
  # エントリのタイトルを分割
  split_titles = split_title(entry.title)
  
  # エントリのURLでツイッター検索
  client = Twitter::Client.new
  result   = client.search(entry.url, :count => @twitter_search_count, :result_type => "recent", :since_id => 0).results.reverse
  # 検索結果を加工してcommentsに格納
  result.each do |status|
    # ツイートがリツイートならスキップ（他のツイートをリツイートしたものなら）
    if status.retweeted_status
        next
    end        
    # エントリの短縮URLを取得
    if tiny_url == nil && status.urls.size > 0
      tiny_url = status.urls[0].url
    end
    
    # 検索結果をCommentオブジェクトの形に直す
    comment = tweet_to_comment(status, entry.id)
    # ツイートの本文からURLや記事タイトルを除いたコメントのみを取り出す
    comment.text = pickup_comment_from_tweet(comment.text, entry.title, split_titles)
    # エントリの本文と一致する記事は削除
    comment.text = is_tweet_not_entry_text?(comment.text, entry.description)

    if comment.text != false
      comments << comment
    end
  end
  
  return comments
end

=begin  
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
=end  
    
  
    
end