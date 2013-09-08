#
#
#
#
class Site < ActiveRecord::Base
  attr_accessible   :name, :url, :feed_url, :category_id, :registered_from, :rank
  
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
  

  
end
