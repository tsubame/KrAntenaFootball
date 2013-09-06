class Article < ActiveRecord::Base
  # attr_accessible :title, :body
  
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
  
  
  # 
  # 
  # 
  def get_todays_by_rss
    # サイトを全て取得
    
    # サイトの件数ループ
      # RSSで記事取得
        # 記事の件数ループ
        # 未保存分をDBに保存
  end
    
  # 
  # 
  # 
  def update_rt_counts
    # 24時間以内の記事取得（時間はもう少し狭める？）
    
    # TwitterAPIでRT数を取得
    
  end
end 
