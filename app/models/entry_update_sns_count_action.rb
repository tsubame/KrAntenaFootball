# -*- encoding: UTF-8 -*-
require 'open-uri'
require 'rss'
require 'assets/sns_count_getter'

# entriesテーブル内の最近の記事の
# ソーシャルサイトでのシェア数を取得し、テーブル内のデータを更新
#
class EntryUpdateSnsCountAction
  
  # この時間より前の記事のシェア数は取得しない 24 → 24時間以内の記事のみが対象
  #MAX_UPDATE_HOUR  = 24
  MAX_UPDATE_HOUR  = 24
  # この件数より前の記事のシェア数は取得しない 180 → 最近180件の記事のみが対象
  MAX_UPDATE_COUNT = 200
  
  def initialize
    @getter = SnsCountGetter.new
    @update_hour  = MAX_UPDATE_HOUR
    @update_count = MAX_UPDATE_COUNT
  end
    
  # 処理実行 
  #
  def exec
    model = Entry.new
    # 最近の記事を取得してURLを配列に格納
    entries = model.select_recent_data_limited(@update_hour, @update_count)
    puts "#{entries.size}件の記事"
    urls = []
    entries.each do |entry|
      urls << entry.url
    end
    # SNSのシェア数を取得
    results = @getter.exec(urls)
        
    entries.each do |entry|
      entry.tw_count = results[entry.url][:tw_count]
      entry.fb_count = results[entry.url][:fb_count]
    end
    
    entries.each do |entry|
      entry.save
    end
  end

end
