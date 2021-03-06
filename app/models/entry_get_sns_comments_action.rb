# -*- encoding: UTF-8 -*-
require 'open-uri'
require 'assets/twitter_searcher'

# entriesテーブル内の最近のエントリに対する
# SNSでのコメントを取得し、commentsテーブルに保存
#
class EntryGetSnsCommentsAction
  
  # この時間より前のエントリのコメントは取得しない 24 → 24時間以内の記事のみが対象
  MAX_UPDATE_HOUR  = 24
  # この件数より前のエントリのコメントは取得しない 180 → 最近180件の記事のみが対象
  MAX_UPDATE_COUNT = 10 #100
  
  def initialize
    @update_hour  = MAX_UPDATE_HOUR
    @update_count = MAX_UPDATE_COUNT
  end
    
  # 処理実行 
  #
  def exec
    # 最近のエントリを取得
    model = Entry.new
    
    # カテゴリーを取得
    categories = Category.all
    entries = []
    # カテゴリーごとの記事を取得
    categories.each do |cat|
      entries += model.select_todays_pop_entries(cat.id, MAX_UPDATE_COUNT)
    end
    
    #entries = model.select_recent_data_limited(@update_hour, @update_count)
    
    puts "#{entries.size}件の記事"

    # コメント取得
    comments = get_twitter_comments(entries)
    # DBに保存
    comments.each do |comment|      
      comment.save_if_not_exists
    end
  end

  # エントリに対するツイッターのコメントを取得
  #
  # @param  [Array] entries
  # @return [Array] comments
  def get_twitter_comments(entries)
    # エントリのURLを配列に格納
    urls = []    
    entries.each do |entry|
      urls << entry.url      
    end
    
    # URLをキーワードに検索
    searcher = TwitterSearcher.new
    comments_hash = searcher.exec(entries)
    comments = []
    
    comments_hash.each do |key, value|
      puts ""; puts key
      value.each_with_index do |c, i|
        puts "#{i} #{c.text}"
      end
    end  
      
    # エントリーIDをコメントにセット
    entries.each do |entry|
      comments_of_entry = comments_hash[entry.url]
      begin
        comments_of_entry.each do |comment|
          comment.entry_id = entry.id
          comments << comment
        end
      rescue => e
        puts e.message
      end  
    end
    
    return comments
  end

end
