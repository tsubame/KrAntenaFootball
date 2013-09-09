# coding: utf-8
require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  
  # テストの前の処理 
  # データの登録
  #
  def setup
    @article = Article.new

    # データの登録 今日、昨日のデータを合計50件登録
    50.times do |i|
      article = Article.new
      article.url = "http://data_#{i}"
      article.site_id = 1 #fixtures/sites.ymlのid:1のデータ
      article.published_at = Time.now - (3600 * i)
      article.save_if_not_exists
    end
  end
  
  def teardown
    @article = nil
  end
  
  # select_recent_data
  # 前提条件: articlesテーブルにデータが登録されている
  #
  test "select_recent_data 24時間内のデータ、48時間内のデータが取得できる" do
    articles = @article.select_recent_data(24)
    assert_not_equal articles.size, 0
    articles = @article.select_recent_data(48)
    assert_not_equal articles.size, 0
  end  
  
  # select_recent_data_limited
  # 前提条件: articlesテーブルに24時間内のデータが2件以上登録されている
  #
  test "select_recent_data_limited 24時間内のデータが1件、続いて2件取得できる" do
    articles = @article.select_recent_data_limited(24, 1)
    assert_equal articles.size, 1
    articles = @article.select_recent_data_limited(24, 2)
    assert_equal articles.size, 2
  end  
  
  # select_todays_pop_articles
  # 前提条件： articlesテーブルに、sites_id:1 かつ 24時間内のデータが10件以上登録されている
  #
  test "select_todays_pop_articles 指定したカテゴリIDのデータが10件取得できる" do
    expected_category_id = 0
    count = 10
    
    articles = @article.select_todays_pop_articles(expected_category_id, count)
    assert_equal count, articles.size    
    articles.each do |article|
      assert_equal expected_category_id, article.site.category_id
    end
  end
  
  # find 
  # 関連するモデルを取得できる
  #
  test "find 関連するモデルを取得する" do
    article = Article.find(1)
    assert_equal article.site.name, "サッカーキング"
  end  
  
  # 前提条件：テーブル内にデータが200件登録されている
  #
  test "select_recent_data_limited 指定した日時、件数のデータが取得できる" do
    hour = 24
    count = 10

    articles = @article.select_recent_data_limited(hour, count)    
    articles.each do |article|
      assert article.published_at > Time.now - (3600 * hour)
    end
    assert_equal articles.size, count
  end  
  
end
