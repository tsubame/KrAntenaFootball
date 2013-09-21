# -*- encoding: utf-8 -*-

class Entry < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :site
  
  # 今日の人気記事を取得
  # fb_count ＋ tw_count の合計順に取得
  #
  # @param [integer] category_id
  # @param [integer] count
  def select_todays_pop_entries(category_id, count)
    now = Time.now
    date = now - (3600 * 24)
    entries = Entry.joins(:site).
      where("entries.category_id = ? AND entries.published > ?", category_id, date).
      order('entries.fb_count + entries.tw_count desc').limit(count)
  end
  
  # 同じURLのデータが無ければDBに保存
  # 
  # @return [bool] 保存できればtrue
  def save_if_not_exists    
    begin
      save
    rescue => e
      puts '保存に失敗しました' + e.message
      return false
    end
    
    return true 
  end
  
  # 件数、時間（最近◯時間内のデータ）を指定してデータを取得
  # 
  # @param [integer] count
  # @param [integer] hour
  # @return [Array] sites
  def select_recent_data_limited(hour, count)
    now = Time.now
    date = now - (3600 * hour)
    entries = Entry.where("published > ?", date).order('published').limit(count).offset(0)
  end
  
  # 件数、時間（最近◯時間内のデータ）を指定してデータを取得
  # 
  # @param [integer] count
  # @param [integer] hour
  # @return [Array] sites
  def select_recent_data(hour)
    now = Time.now
    date = now - (3600 * hour)
    entries = Entry.where("published > ?", date).order('published')
  end
  
  # 時間（最近◯時間内〜◯時間内のデータ）を指定してデータを取得
  # 
  # @param [integer] hour_from
  # @param [integer] hour_to
  # @return [Array] sites
  def select_data_in_era(hour_from, hour_to)
    now = Time.now
    date_from = now - (3600 * hour_from)
    date_to = now - (3600 * hour_to)
    entries = Entry.where("published > ? AND published < ?", date_from, date_to).order('published')
  end
end
