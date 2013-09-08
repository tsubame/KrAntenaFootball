#
#
class ArticleController < ApplicationController
  
  # カテゴリごとに表示する件数
  GET_COUNT_OF_CATEGORY = 10
  
  # 記事を表示
  # 
  def index
    @articles_of_category = []
    model = Article.new
    
    # カテゴリーを取得
    @categories = Category.all
    # カテゴリーごとの記事を取得
    @categories.each do |cat|
      @articles_of_category << model.select_todays_pop_articles(cat.id, GET_COUNT_OF_CATEGORY)
    end    
  end
  
  # RSSから記事を取得
  #
  def create_from_rss
    action = ArticleCreateFromRssAction.new
    action.exec
    index
    render "index"
  end

  # SNSのシェア数更新
  #
  def update_share_count
    action = ArticleUpdateShareCountAction.new
    action.exec
    index
    render "index"
  end
  
end
