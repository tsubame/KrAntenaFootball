# coding: utf-8
require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @article = Article.new
  end
  
  def teardown
    @article = nil
  end
  
  # select_todays_pop_articles
  # 前提条件
  # テーブル内に今日のデータが10件登録されている
  #
  test "select_todays_pop_articles データが取得できる" do
    expected_category_id = 0
    count = 10
    
    10.times do |i|
      article = Article.new
      article.url = "http://#{i}"
      article.site_id = 1
      article.published_at = Time.now - (3600 * 20)
      article.tw_retweet = rand(100)
      article.fb_share = rand(100)
      article.save_if_not_exists
    end
    
    articles = @article.select_todays_pop_articles(expected_category_id, count)
    assert_equal count, articles.size
    
    articles.each do |article|
      p article
      assert_equal expected_category_id, article.site.category_id
    end
  end
  
  # 関連するモデルを取得する
  #
  test "find 関連するモデルを取得する" do
    article = Article.find(1)
    #p article.site
    assert_equal article.site.name, "サッカーキング"
  end  
  
  # 前提条件
  # テーブル内にデータが200件登録されている
  #
  test "select_recent_data_limited 指定した日時、件数のデータが取得できる" do
    hour = 24
    count = 10
    save_articles = []
    200.times do |i|
      article = Article.new
      article.url = "http://#{i}"
      article.published_at = Time.now - (3600 * rand(50))
      article.save_if_not_exists
    end
    
    articles = @article.select_recent_data_limited(hour, count)
    #puts articles.size  
    
    articles.each do |article|
      assert article.published_at > Time.now - (3600 * hour)
    end
    assert_equal articles.size, count
  end  
  
  # 前提条件
  #
  test "select_recent_data_limited 指定した件数のデータが取得できる" do
    articles = @article.select_recent_data_limited(28, 1)
    assert_equal articles.size, 1
    articles = @article.select_recent_data_limited(28, 2)
    assert_equal articles.size, 2
  end  
  
  # 前提条件
  # テーブル内にデータが200件登録されている
  #
  test "select_recent_data 指定した日時以降のデータが取得できる" do
    articles = @article.select_recent_data(24)
    #puts articles.size  
    #p articles
    assert_not_equal articles.size, 0
    
    articles = @article.select_recent_data(26)
    #puts articles.size  
    #p articles
    assert_not_equal articles.size, 0
  end  
end
