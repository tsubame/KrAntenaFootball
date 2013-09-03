# coding: utf-8
require 'test_helper'

class NewsTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  # 調べること。
  # テスト用のDBはどうなる？
  # fixtureの使い方
  # バリデーションは？
  
  def setup
    #@news = News.new
  end
  
  def teardown
    #@news = nil
  end
  
  #
  # save
  #
  test "save" do
    
  end
  
  # 
  # save_if_not_existsのテスト
  #
  #
  test "save_if_not_exists" do
    # 同じURLのデータがなければ正常に保存できるか 返り値はtrue
    news = News.new
    news.title    = 'ニュース｜サッカー｜スポーツナビ'
    news.url      = 'http://sportsnavi.yahoo.co.jp/sports/soccer/'
    news.site_id  = 0 
    res = news.save_if_not_exists()
    assert_equal res, true
    
    data = News.all
    #p data
    
    # 同じURLのデータがあれば保存できないか 返り値はfalse    
    news = News.new
    news.title    = 'test'
    news.url      = 'http://sportsnavi.yahoo.co.jp/sports/soccer/'
    res = news.save_if_not_exists()
    assert_equal res, false    
    
    res = news.save_if_not_exists()
    assert_equal res, false
    
    data = News.all
    #p data
  end
end
