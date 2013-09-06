# -*- encoding: UTF-8 -*-

require 'test_helper'

class ArticleCreateFromRankActionTest < ActiveSupport::TestCase
  
  def setup
    @action = ArticleCreateFromRankAction.new
  end
  
  
# 要リファクタリング （まとめる）
  
  # ライブドアのテスト用フィードURL
  SAMPLE_FEED_URL_LIVEDOOR = "http://blog.livedoor.jp/domesoccer/index.rdf"
  
  # FC2のテスト用フィードURL
  SAMPLE_FEED_URL_FC2 = "http://nofootynolife.blog.fc2.com/?xml"
  
=begin  

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
  
  test "get_articles_from_rss ライブドアブログのフィードURLを渡した時、返ってきた配列のサイズが一定以上である" do
    articles = @action.get_articles_from_rss(SAMPLE_FEED_URL_LIVEDOOR)    
    min_expected = 2
    assert min_expected <= articles.size
  end
  
  test "get_articles_from_rss ライブドアブログのフィードURLを渡した時、記事のタイトル、URLの文字列長が1以上" do
    articles = @action.get_articles_from_rss(SAMPLE_FEED_URL_LIVEDOOR) 
        
    articles.each do |article|
      assert 1 <= article.title.length
      assert 1 <= article.url.length
      #p article
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

  test "get_articles_from_rss FC2ブログのフィードURLを渡した時、記事のタイトル、URLの文字列長が1以上" do
    articles = @action.get_articles_from_rss(SAMPLE_FEED_URL_FC2)    
        
    articles.each do |article|
      assert 1 <= article.title.length
      assert 1 <= article.url.length
      #p article
    end
  end
  
  #
  #
  #
  test "exec" do
    #site_new_action = SiteCreateFromRankAction.new
    #site_new_action.exec
    
    #p sites = Site.all
    #assert 50 <= sites.size
    
    #puts sites.size
    #@action.exec
    #articles = Article.all
    
    #assert 20 <= articles.size
  end
  
  #
  #
  test "get_articles_to_array" do
    @action.get_articles_to_array(SAMPLE_FEED_URL_FC2)    
    articles = @action.articles
        
    articles.each do |article|
      #assert 1 <= article.title.length
      #assert 1 <= article.url.length
    end
  end


  
  # マルチスレッドのテスト
  #
  #
  test "get_articles_by_multi_threads " do
    feed_urls = [
      SAMPLE_FEED_URL_LIVEDOOR,
      SAMPLE_FEED_URL_FC2,
      "http://www.calciomatome.net/index.rdf",
      "http://footballinflu.blog.fc2.com/?xml",
      "http://blog.livedoor.jp/aushio/index.rdf",
      "http://blog.livedoor.jp/footcalcio/index.rdf",
      "http://blog.livedoor.jp/aushio/index.rdf"
    ]
    
    #p articles = @action.get_articles_by_multi_threads(feed_urls)
    #assert_not_equal articles.size, 0
  end
  
  # マルチスレッドでの記事取得
  #
  #
  test "get_articles_from_rss_by_thread " do
    #articles_lv = @action.get_articles_from_rss_by_thread(SAMPLE_FEED_URL_LIVEDOOR)    
    #articles_fc2 = @action.get_articles_from_rss_by_thread(SAMPLE_FEED_URL_FC2)
    
    #p articles_fc2
    #p articles_lv
    #assert_not_equal articles_fc2, false
    #assert_not_equal articles_lv, false
  end

  # マルチスレッドのテスト
  #
  #
  test "get_articles_by_multi_threads_limited " do
    feed_urls = [
      SAMPLE_FEED_URL_LIVEDOOR,
      SAMPLE_FEED_URL_FC2,
      "http://www.calciomatome.net/index.rdf",
      "http://footballinflu.blog.fc2.com/?xml",
      "http://blog.livedoor.jp/aushio/index.rdf",
      "http://blog.livedoor.jp/footcalcio/index.rdf"
    ]
    @action.max_thread = 2
    articles = @action.get_articles_by_multi_threads_limited(feed_urls)
    assert_not_equal articles.size, 0
  end
=end   

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
