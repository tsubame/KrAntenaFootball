# -*- encoding: utf-8 -*-
require 'test_helper'
require 'word_splitter'

class KeywordTest < ActiveSupport::TestCase

  def setup
    @keyword  = Keyword.new
  end
  
  def teardown
    @keyword = nil
  end
  
  #
  #
  #
  test "get_todays_hot_keywords" do
    multi_words = @keyword.get_todays_hot_keywords
    
    p multi_words
  end

  # get_multiple_words 正常に取り出せるか
  #
  # 
  test "get_multiple_words" do
    words = ["エジル", "ユナイテッド", "の", "ユナイテッド", "エジル", "エジル", "の", "あ", "サッカー"]
    expected = ["エジル", "ユナイテッド"]      
    res = @keyword.get_multiple_words(words)
    assert_equal expected, res
    
    # 文字列以外が入っている場合
    words = ["エジル", 111, "の", "ユナイテッド", "エジル", "エジル", "の", "ユナイテッド", "", "", "サッカー", nil, "サッカー"]
    expected = ["エジル", "ユナイテッド", "サッカー"]
    res = @keyword.get_multiple_words(words)
    assert_equal expected, res
  end
  
  # get_multiple_words 異常な値を与えた場合
  # 配列以外を与えた場合の返り値は全てnil
  #
  test "get_multiple_words 異常な値を与えた場合" do    
    expected = nil 
      
    # 空の配列
    words = []
    res = @keyword.get_multiple_words(words)
    assert_equal [], res
    
    # 配列以外を与えた場合
    words = 22
    res = @keyword.get_multiple_words(words)
    assert_equal expected, res
    
    words = nil
    res = @keyword.get_multiple_words(words)
    assert_equal expected, res
  end
  
  # get_multiple_words 正常に取り出せるか
  #
  # 
  test "remove_ng_word" do
    words = ["エジル", "ユナイテッド", "ゴール", "FW", "サッカー"]
    expected = ["エジル", "ユナイテッド"]      
    res = @keyword.remove_ng_word(words)
    assert_equal expected, res
  end
  
end
