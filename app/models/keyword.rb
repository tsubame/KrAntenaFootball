# -*- encoding: utf-8 -*-
require 'assets/word_splitter'

#
#
#
class Keyword < ActiveRecord::Base
  
  # キーワードに含めない言葉のリストも作っておく。
  
  # NGワード ホットキーワードに含めない言葉の配列
  NG_WORDS = ["FW", "DF", "MF", "GK", "リーグ", "ゴール", "アシスト", "サッカー", "ニュース",
    "スタメン", "ユース", "国際", "大会", "ぶり", "スレ", "まとめ", "J1", "J2", "チーム",
    "2013", "2014", "13-14", "14-15", "extra", "vs",
    "試合", "結果", "選手", "監督", "情報", "加入", "決定", "確定", "欠場", "期限",
    "日本", "海外", "欧州",  "代表", "予選", "同点", "逆転"]
  
  # キーワードが何回出てきたらホットキーワードとみなすか
  HOT_KEY_COUNT = 3
  
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
      row = splitter.pickup_noun(news.title)
      words += row
    end
    
    # 重複する単語を取り出す
    multi_words = get_multiple_words_to_hash(words)
    
    # NGワードを取り除く
    keywords = remove_ng_word_from_hash(multi_words)
    
    hot_keywords = {}
    # ソート
    keywords.sort_by{|key, value| -value}.each do|key, value|
      hot_keywords[key] = value
    end
    
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
  # 配列の中の文字列から重複しているものを取り出し、それらをハッシュにして返す
  #
  # ["aa", "aa", "aa", "bb", "bb", "c", "c", "dd"] -> {"aa" => 3, "bb" => 2}
  #
  # @param  [Array] words
  # @return [Array] multi_words エラー時はnilを返す
  #
  def get_multiple_words_to_hash(words)
    if words.kind_of?(Array) == false 
      return nil 
    end
    
    multi_words = {}
            
    words.each do |word|
      # 文字列以外ならスキップ
      if word.kind_of?(String) == false
        next
      end
      
      # multi_wordsに保存したものと同じならスキップ
      res = multi_words.key?(word)
      next if res == true
      
      # words内の他の要素に同じ値があれば保存   
      count = get_count_of_words(words, word)
      multi_words[word] = count if HOT_KEY_COUNT <= count
    end
    
    return multi_words    
  end
  
  # 配列の中の出現数を返す
  #
  # @param [Array]    words
  # @param [String]   target
  # @return [integer] 
  def get_count_of_words(words, target)
    count = 0
    
    words.each do |word|  
      if word == target
        count += 1
      end      
    end
    
    return count
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
  
#
# ハッシュからNGワード(定数 NG_WORDS内の文字)を取り除いて返す
#
# @param  [Hash] words
# @return [Hash] res_words エラー時はnilを返す
#
def remove_ng_word_from_hash(words)
  # ハッシュ以外なら終了
  if words.kind_of?(Hash) == false 
    return nil 
  end
  
  NG_WORDS.each do |word|
    words.delete(word)
  end
  
  return words
end
  
end
