# coding: utf-8
require 'test_helper'

class NewsTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  # 調べること。
  # バリデーションは？
  
  def setup
    @news = News.new
  end
  
  def teardown
    @news = nil
  end
  
  #
  # save
  #
  test "save" do
    
  end
  
  # save_todays_newsのテスト
  #
  #
  test "save_todays_newsで正常にニュースが保存できる" do
    @news.save_todays_news    
    data = News.all
    data.each do |d|
      #p d
    end    
    # 正常ならDBに3件以上データが有る
    assert_not_equal data.size, 0    
    assert_not_equal data.size, 1
    assert_not_equal data.size, 2
  end
  
  # get_todays_newsのテスト
  #
  #
  test "get_todays_newsで正常にニュースが取得できる" do
    data = @news.get_todays_news    
    data.each do |d|
      #p d
    end
    # 正常なら1件以上データが有る
    assert_not_equal data.size, 0
  end
  
  # 
  # save_if_not_existsのテスト
  #
  #
  test "save_if_not_exists" do
    # 同じURLのデータがなければ正常に保存できる 返り値はtrue
    news = News.new
    news.title    = 'ニュース｜サッカー｜スポーツナビ'
    news.url      = 'http://sportsnavi.yahoo.co.jp/sports/soccer/'
    news.site_id  = 0 
    
    res = news.save_if_not_exists()
    assert_equal res, true
    
    # 同じURLのデータがあれば保存できない 返り値はfalse    
    news = News.new
    news.title    = 'test'
    news.url      = 'http://sportsnavi.yahoo.co.jp/sports/soccer/'
    res = news.save_if_not_exists()
    assert_equal res, false    
    
    res = news.save_if_not_exists()
    assert_equal res, false
  end
end
