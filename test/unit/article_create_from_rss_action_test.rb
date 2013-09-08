# -*- encoding: UTF-8 -*-

require 'test_helper'

class ArticleCreateFromRssActionTest < ActiveSupport::TestCase
  
  def setup
    @action = ArticleCreateFromRssAction.new
  end
  
  
# 要リファクタリング （まとめる）
  
  # ライブドアのテスト用フィードURL
  SAMPLE_FEED_URL_LIVEDOOR = "http://blog.livedoor.jp/domesoccer/index.rdf"
  
  # FC2のテスト用フィードURL
  SAMPLE_FEED_URL_FC2 = "http://nofootynolife.blog.fc2.com/?xml"

  # ライブドアブログのフィードURLを渡した時
  #
  #
  test "get_articles_from_rss ライブドアブログのフィードURLを渡した時、返り値がfalseではない" do
    articles = @action.get_articles_from_rss(SAMPLE_FEED_URL_LIVEDOOR)
    assert_not_equal articles, false
    
    if articles == false
      puts @action.error_message
    end
  end
  
  # FC2ブログのフィードURLを渡した時
  #
  #
  test "get_articles_from_rss FC2ブログのフィードURLを渡した時、返り値がfalseではない" do
    articles = @action.get_articles_from_rss(SAMPLE_FEED_URL_FC2)
    assert_not_equal articles, false
    
    if articles == false
      puts @action.error_message
    end
  end

  # マルチスレッドのテスト
  #
  #
  test "get_articles_parallel_limited " do
    feed_urls = [
      SAMPLE_FEED_URL_LIVEDOOR,
      SAMPLE_FEED_URL_FC2,
      "http://www.calciomatome.net/index.rdf",
      "http://footballinflu.blog.fc2.com/?xml",
      "http://blog.livedoor.jp/aushio/index.rdf",
      "http://blog.livedoor.jp/footcalcio/index.rdf"
    ]
    
    sites = []
    feed_urls.each do |url|
      site = Site.new
      site.feed_url = url
      site.id = 0
      sites << site
    end
    
    @action.max_thread = 2
    @action.get_articles_parallel_limited(sites)
    articles = @action.articles
    assert_not_equal articles.size, 0
  end

  #
  #
  #
  test "exec" do
    site_new_action = SiteCreateFromRankAction.new
    site_new_action.exec
    
    sites = Site.all
    puts sites.size
    assert 50 <= sites.size    
    
    #@action.max_thread = 5
    #@action.max_thread = 40
    @action.exec
    
    articles = Article.all
    puts "#{sites.size}件のサイトを処理"
    puts "#{articles.size}件の記事を取得"
    assert 20 <= articles.size
  end
  
end
