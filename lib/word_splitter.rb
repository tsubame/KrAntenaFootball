require 'MeCab'
require 'kconv'

#
#
#
class WordSplitter
  
  # 
  # Mecabを使って文字列を単語に分ける
  #
  # @param  [String] str
  # @return [Array] words
  def split_str_to_words(str)      
    if str.kind_of?(String) == false
      return []
    end

    wakati = MeCab::Tagger.new('-O wakati')
    word_str = wakati.parse(str)
    word_str = word_str.toutf8
    words = word_str.split(" ")
    
    return words
  end  
  
#
#=== 以下、不要？  
#  
  # Yahooキーフレーズ抽出API
  YAHOO_KEYP_API_URL = "http://jlp.yahooapis.jp/KeyphraseService/V1/extract"
  # Yahoo アプリケーションID
  YAHOO_APP_ID = "dj0zaiZpPVNGb1E1Z0M3TEJ0aSZzPWNvbnN1bWVyc2VjcmV0Jng9N2U-"
  # 同シークレット
  YAHOO_SECRET = "0da2901fafa0e02a82b146b371b8b71448b69679"
  # Yahooキーフレーズ抽出APIへのリクエスト用URL。最後に対象の文字列をくっつけて送信
  KEYP_REQUEST_URL = YAHOO_KEYP_API_URL + "?appid=" + YAHOO_APP_ID + "&sentence="  
  
  # YAHOO キーフレーズ抽出APIにリクエストを送り、結果をJSONPで取得
  #
  # @param  [String] str
  # @return [String] json
  def request_yahoo_keyp_api(str)
    encode_str = CGI.escape(str)
    url = KEYP_REQUEST_URL + encode_str    
    json = http_get(url)
    
    return json
  end

  # Httpリクエストを発行し、HTTPレスポンスを文字列で返す
  # 失敗した場合はnilが帰る
  #
  # @param [String]  url
  # @return [String]
  def http_get(url)
    # 文字列でなければnilを返す
    if url.kind_of?(String) == false
      return nil
    end
    
    begin
      uri = URI(url)
      res = uri.read      
    rescue => e
      return nil
    end

    return res
  end
  
end