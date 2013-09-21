# -*- encoding: UTF-8 -*-

#
#
#
#
class SiteCreateAutoAction
  #include ActiveModel::Conversion
  #attr_accessible   :name, :url, :feed_url, :category_id, :registered_from, :rank
  
  #
  #
  # 
  def exec(id = nil)
    sites = get_blog_sites(id)   
    sites = categorize(sites)
    
    sites.each do |site|
      site.save_if_not_exists
    end
  end
  
  #
  #
  # 
  def get_sites_and_register
    sites = get_blog_sites
    
    #sites = categorize(sites)
    
    sites.each do |site|
      site.save_if_not_exists
    end
  end
  
  #
  #
  #
  def categorize(sites)
    getter = PopularBlogGetter.new
    sites = getter.auto_categorize(sites)
    
    return sites
  end
  
  #
  #
  #
  def get_blog_sites(cat_id)
    all_sites = []
    getter = PopularBlogGetter.new
    rank_pages = BlogRankPage.all
    sites = []
    
    rank_pages.each do |page|
      sites = []
      #puts "#{page.category_id} #{cat_id}"

      if cat_id != nil
        if page.category_id != cat_id
          puts "スキップします#{page.category_id}"
          next
        end   
      end    

      if page.blog_service_name == "livedoor"
        #p page.feed_url
        sites = getter.get_livedoor_blogs(page.feed_url)
      elsif page.blog_service_name == "fc2"
        #p page.url
        sites = getter.get_fc2_blogs(page.url)
      elsif page.blog_service_name == "Ameba"
        #p page.url
        sites = getter.get_ameba_blogs(page.url)
      end
      sites.each do |site|
        site.category_id = page.category_id
        site.sub_category_id = page.sub_category_id
      end
      
      all_sites += sites     
    end
 
    return all_sites
  end
  
  def get_poli_econo_blog_sites
    all_sites = []
    getter = PopularBlogGetter.new
    rank_pages = BlogRankPage.all
    sites = []
    
    rank_pages.each do |page|
      sites = []
      
      if page.category_id != 0
        next
      end  
        
      if page.blog_service_name == "livedoor"
        #p page.feed_url
        sites = getter.get_livedoor_blogs(page.feed_url)
      elsif page.blog_service_name == "fc2"
        #p page.url
        sites = getter.get_fc2_blogs(page.url)
      elsif page.blog_service_name == "Ameba"
        #p page.url
        sites = getter.get_ameba_blogs(page.url)
      end
      sites.each do |site|
        site.category_id = page.category_id
        site.sub_category_id = page.sub_category_id
      end
      
      all_sites += sites
    end
    
    return all_sites
  end
  
end
