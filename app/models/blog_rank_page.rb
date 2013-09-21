class BlogRankPage < ActiveRecord::Base
  attr_accessible   :title, :url, :feed_url, :category_id, :sub_category_id, :blog_service_name, :max_register_count
end
