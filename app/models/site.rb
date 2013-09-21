# -*- encoding: utf-8 -*-

#
#
#
#
class Site < ActiveRecord::Base
  attr_accessible  :title, :url, :feed_url, :category_id, :sub_category_id, :registered_from, :rank

  # 同じURLのデータが無ければDBに保存
  # 
  # @return [bool] 保存できればtrue
  def save_if_not_exists    
    begin
      save
    rescue => e
      puts @error_message = e.message
      Rails.logger.error(e.message)
      return false
    end
    
    return true 
  end
  
  # URLを指定してデータを取得
  # 
  # @param [String] url
  # @return [Site] site
  def select_by_url(url)
    sites = Site.where(:url => url)
    if 0 < sites.size
      return sites[0]
    else
      return false
    end
  end
  
  
end
