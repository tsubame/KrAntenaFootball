# -*- encoding: UTF-8 -*-

#
#
#
#
class SiteCreateFromRankAction
  #include ActiveModel::Conversion
  #attr_accessible   :name, :url, :feed_url, :category_id, :registered_from, :rank
  
  # 
  def exec
    getter = PopularBlogGetter.new
    sites = getter.exec
    
    sites.each do |site|
      site.save_if_not_exists
    end
  end
  
end
