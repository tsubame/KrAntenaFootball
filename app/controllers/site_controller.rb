require 'assets/popular_blog_getter'

#
#
#
class SiteController < ApplicationController
  def index
  end

  def new
  end
  
  # ランキングサイトからブログを登録
  #
  #
  def create_from_rank
    action = SiteCreateFromRankAction.new
    action.exec
  end
end
