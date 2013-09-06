# -*- encoding: utf-8 -*-
require 'test_helper'
require 'assets/word_splitter'

class WordSplitterTest < ActiveSupport::TestCase
  
  def setup
    @splitter = WordSplitter.new
  end
  
  def teardown
    @splitter = nil
  end
  
  #
  # split_str_to_wordsのテスト
  # 正常に結果が取得出来る
  #
  test "split_str_to_words 正常に結果が取得できる" do
    
    str = "ユナイテッド加入のフェライニ" 
    expected = ["ユナイテッド", "加入", "の", "フェライニ"]
    res = @splitter.split_str_to_words(str)

    res.each do |r|
      #puts r
    end
    
    assert_equal expected, res
  end
  
  #
  # split_str_to_wordsのテスト
  # 不正なデータを渡した場合に[]が帰ってくる 
  #
  test "split_str_to_words 不正なデータを渡した場合" do    
    # 返り値はすべて[]
    expected = []
      
    str = "" 
    res = @splitter.split_str_to_words(str)    
    assert_equal expected, res
    
    str = nil
    res = @splitter.split_str_to_words(str)    
    assert_equal expected, res
    
    str = 33
    res = @splitter.split_str_to_words(str)    
    assert_equal expected, res
  end
  
  #
  # pickup_nounのテスト
  # 正常に結果が取得出来る
  #
  test "pickup_noun 正常に結果が取得できる" do
    
    str = "ユナイテッド加入のフェライニ、古巣から連続ゴールを決める" 
    expected = ["ユナイテッド", "フェライニ", "古巣", "ゴール"]
    res = @splitter.pickup_noun(str)    
    assert_equal expected, res
    res.each do |r|
      puts r
    end
    
    str = "モウリーニョ、ジダン、S・ラモスがベイル移籍を語る"
    expected = ["モウリーニョ", "ジダン", "ラモス", "ベイル"]
    res = @splitter.pickup_noun(str) 
    res.each do |r|
      puts r
    end
    assert_equal expected, res
    
    str = "長谷部「すっきりした」＝ニュルンベルク移籍で―独サッカー"
    expected = ["長谷部", "ニュルンベルク", "サッカー"]
    res = @splitter.pickup_noun(str) 
    res.each do |r|
      puts r
    end
    assert_equal expected, res
  end
  
  
  
  
=begin  

  #
  # http_getのテスト
  # Webリクエストが正常に発行できる
  #
  test "http_get Webリクエストが正常に発行できる" do
    url = 'http://sportsnavi.yahoo.co.jp/'
    res = @splitter.http_get(url)
    assert_not_equal nil, res
  end
  
  #
  # http_getのテスト
  # 不正なURLを渡した場合 nilが帰ってくる
  #
  test "http_get 不正なURLを渡した場合" do
    url = 'h'
    res = @splitter.http_get(url)
    assert_equal nil, res
    
    url = '有頂天家族'
    res = @splitter.http_get(url)
    assert_equal nil, res
    
    url = ''
    res = @splitter.http_get(url)
    assert_equal nil, res
    
    url = 33
    res = @splitter.http_get(url)
    assert_equal nil, res
    
    url = nil
    res = @splitter.http_get(url)
    assert_equal nil, res
  end
  
  #
  # request_yahoo_keyp_apiのテスト
  # 正常にレスポンスが帰ってくる
  #
  test "request_yahoo_keyp_api 正常に結果が取得できる" do
    
    str = "ユナイテッド加入のフェライニ「夢だった」" 
    #str = "ManUtdalives"
    res = @splitter.request_yahoo_keyp_api(str)    
    puts res
    
    str = "大物選手の移動が相次いだビッグサマー １３−１４シーズン夏の欧州移籍リスト"
    res = @splitter.request_yahoo_keyp_api(str)    
    puts res
    
    str = "アーセナル、エジル獲得を発表"
    res = @splitter.request_yahoo_keyp_api(str)    
    puts res
  end
  
=end
  
end
