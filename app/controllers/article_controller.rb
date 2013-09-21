# coding: utf-8
#
#
class ArticleController < ApplicationController
  
  # カテゴリごとに表示する件数
  GET_COUNT_OF_CATEGORY = 30
  
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
    #action = ArticleCreateFromRssAction.new
    action = ArticleFetchAction.new
    action.exec
    index
    render "index"
  end

  # SNSのシェア数更新
  #
  def update_sns_count
    action = ArticleUpdateSnsCountAction.new
    action.exec
    index
    render "index"
  end
  
  # テスト、サンプルコードなど
  #
  def sample
    # はてなのHTMLソースを取得
    
    # パース
    
    client = Twitter::Client.new
    q = "ジュビロ"
    
    client.search(q, :count => 10, :result_type => "recent", :since_id => 0).
        results.reverse.map do |status|
        #p status.id
        p "@" + status.from_user
        p status.text
        p status.created_at
        p status.user.profile_image_url
        puts ""
    end

    index
    render "index"    
  end
    
end
