# coding: utf-8

class Article < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :site
  
  # 今日の人気記事を取得
  # fb_share ＋ tw_retweet の合計順に取得
  #
  # @param [integer] category_id
  # @param [integer] count
  def select_todays_pop_articles(category_id, count)
    now = Time.now
    date = now - (3600 * 24)
    articles = Article.joins(:site).
      where("sites.category_id = ? AND articles.published_at > ?", category_id, date).
      order('articles.fb_share + articles.tw_retweet desc').limit(count)
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
    articles = Article.where("published_at > ?", date).order('published_at').limit(count).offset(0)
  end
  
  # 件数、時間（最近◯時間内のデータ）を指定してデータを取得
  # 
  # @param [integer] count
  # @param [integer] hour
  # @return [Array] sites
  def select_recent_data(hour)
    now = Time.now
    date = now - (3600 * hour)
    articles = Article.where("published_at > ?", date).order('published_at')
  end
  
end 
