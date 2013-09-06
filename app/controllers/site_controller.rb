require 'assets/popular_blog_getter'

#
#
#
class SiteController < ApplicationController

  #
  #
  #
  def index
    
  end

  #
  #
  #
  def new
    
  end
  
  # サイト一覧（管理者向け）
  # サイトの編集が可能
  #
  def index_for_admin
    # サイトの一覧を取得
    @sites = Site.all
    @site = Site.new
    #@categories = Category.new
  end
  
  # サイトの編集処理
  #
  def update
    #　更新処理
    p params
    
    form_data = params[:site]
    site = Site.find(form_data[:id])
    site.name = form_data[:name]
    site.category_id = form_data[:category_id].to_i
    site.save
      
    index_for_admin
    render "index_for_admin"
  end
  
  # ランキングサイトからブログを登録
  #
  #
  def create_from_rank
    action = SiteCreateFromRankAction.new
    action.exec
    render "index"
  end
  
  
end
