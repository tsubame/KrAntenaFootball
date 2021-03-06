# coding: utf-8

class Article < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :site
  
  # 今日の人気記事を取得
  # fb_count ＋ tw_count の合計順に取得
  #
  # @param [integer] category_id
  # @param [integer] count
  def select_todays_pop_articles(category_id, count)
    now = Time.now
    date = now - (3600 * 24)
    articles = Article.joins(:site).
      where("sites.category_id = ? AND articles.published > ?", category_id, date).
      order('articles.fb_count + articles.tw_count desc').limit(count)
  end
  
  # 同じURLのデータが無ければDBに保存
  # 
  # @return [bool] 保存できればtrue
  def save_if_not_exists    
    begin
      save
    rescue => e
      #puts '保存に失敗しました' + e.message
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
    articles = Article.where("published > ?", date).order('published').limit(count).offset(0)
  end
  
  # 件数、時間（最近◯時間内のデータ）を指定してデータを取得
  # 
  # @param [integer] count
  # @param [integer] hour
  # @return [Array] sites
  def select_recent_data(hour)
    now = Time.now
    date = now - (3600 * hour)
    articles = Article.where("published > ?", date).order('published')
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
    articles = Article.where("published > ? AND published < ?", date_from, date_to).order('published')
  end
  
end 
