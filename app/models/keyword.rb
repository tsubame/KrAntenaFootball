# -*- encoding: utf-8 -*-
require 'word_splitter'

#
#
#
class Keyword < ActiveRecord::Base
  
  # キーワードに含めない言葉のリストも作っておく。
  
  # NGワード ホットキーワードに含めない言葉の配列
  NG_WORDS = ["FW", "DF", "MF", "GK", "リーグ", "ゴール", "アシスト", "サッカー",
    "2013", "2014", "13-14", "14-15",
    "試合", "結果", "選手", "監督", "情報", "加入", "決定", "確定", "欠場", "日本", "代表", "予選"]
  
  
  #
  # 今日のホットキーワードを取得
  #
  # @return [Array] multi_words
  #
  def get_todays_hot_keywords    
    # 今日のニュースを配列に取得 
    news_model = News.new
    news_row = news_model.get_todays_news
    
    # ニュースのタイトルから単語を取り出す
    splitter = WordSplitter.new
    words = []
    news_row.each do |news|
      row = splitter.split_str_to_words(news.title)
      words += row
    end
    
    # 重複する単語を取り出す
    multi_words = get_multiple_words(words)
    # NGワードを取り除く
    hot_keywords = remove_ng_word(multi_words)
    
    return hot_keywords
  end
  
  
  #
  # 配列の中の文字列から重複しているものを取り出し、それらを配列にして返す
  # ただし、1文字のデータは無視する（重複していても取り出さない）
  #
  # ["aa", "aa", "aa", "bb", "bb", "c", "c", "dd"] -> ["aa", "bb"]
  #
  # @param  [Array] words
  # @return [Array] multi_words エラー時はnilを返す
  #
  def get_multiple_words(words)
    if words.kind_of?(Array) == false 
      return nil 
    end
    
    multi_words = []
            
    while 0 < words.length
      word = words.shift
      # 文字列以外、もしくは1文字ならスキップ
      if word.kind_of?(String) == false
        next
      elsif word.length <= 1
        next
      end
      
      # multi_wordsに保存したものと同じならスキップ
      res = multi_words.index(word)
      next if res != nil
      
      # words内の他の要素に同じ値があれば保存   
      res = words.index(word)
      multi_words.push(word) if res != nil
    end
    
    return multi_words    
  end
  
  
  #
  # 配列からNGワード(定数 NG_WORDS内の文字)を取り除いて返す
  #
  # @param  [Array] words
  # @return [Array] res_words エラー時はnilを返す
  #
  def remove_ng_word(words)
    # 配列以外なら終了
    if words.kind_of?(Array) == false 
      return nil 
    end
    
    res_words = []
    words.each do |word|
      if NG_WORDS.index(word) == nil
        res_words.push(word)
      end
    end
    
    return res_words
  end
  
end
