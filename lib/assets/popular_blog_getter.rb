# -*- encoding: utf-8 -*-
require 'open-uri'
require 'kconv'
require 'rss'

# ライブドア、FC2のブログランキングのサッカー関連カテゴリから、サイトを取得する
# ライブドアからは「サッカー」、「サッカーまとめ」
# FC2からは「サッカー」カテゴリのサイトを取得
#
# ライブドアはRSSで取得する。FC2はWebページからパースする。
#
#
class PopularBlogGetter
  
  # ライブドアブログランキングから取得する件数
  GET_COUNT_FROM_LD = 25
  # 
  GET_COUNT_FROM_AMEBA = 25
  
  # ライブドア 「サッカー」カテゴリ ブログランキングのフィードURL
  LD_SOCCER_FEED_URL = "http://blog.livedoor.com/xml/blog_ranking_cat9.rdf"
  # ライブドア 「サッカーまとめ」カテゴリ ブログランキングのフィードURL
  LD_2CH_SOCCER_FEED_URL = "http://blog.livedoor.com/xml/blog_ranking_cat446.rdf"
  # FC2「サッカー」カテゴリのページURL
  FC2_SOCCER_URL = "http://blog.fc2.com/subgenre/250/"
  # アメーバ「サッカー」カテゴリのページURL
  AMEBA_SOCCER_URL = 'http://ranking.ameba.jp/gr_soccer'  
  # FC2のランキングのサイトURL、タイトルが記述されてる部分の正規表現
  FC2_SITE_TAG_PATTERN = /http:..[\w\.\-\/]+?[^>]+?target[^>]+?title[^>]+?>/mi
  # アメーバ
  AMEBA_TAG_PATTERN  = %r|<dd class="title">.+?</dd>|im
  #
  AMEBA_NAME_PATTERN = %r|http://[\w\.\-/_=?&@:]+">([^<]+)</a|im
  
  
  # ライブドアブログのRSSの接尾辞（サイトのURLの後にこれが付く）
  LIVEDOOR_RSS_SUFFIX = "index.rdf"
  # FC2ブログのRSSの接尾辞（
  FC2_RSS_SUFFIX = "?xml"
  # ライブドアから登録した際のsite.registered_fromの値
  SITE_REG_FROM_LIVEDOOR = "livedoor"
  # FC2から登録した際のsite.registered_fromの値
  SITE_REG_FROM_FC2 = "fc2"
  # amebaから登録した際のsite.registered_fromの値
  SITE_REG_FROM_AMEBA = "ameba"
  
  # エラーメッセージ
  attr_reader :error_message
  
  def initialize
    @error_message = ""
  end
  
  # まとめて実行
  #
  # @return [Array] sites
  def exec
    sites = []
    sites += get_livedoor_soccer_blogs
    sites += get_livedoor_2ch_soccer_blogs
    sites += get_fc2_soccer_blogs
    sites += get_ameba_soccer_blogs
    
    return sites
  end
  
  # 処理内容にエラーがあればtrue
  #
  # @return [Bool] 
  def error?
    if 0 < @error_message.length
      return true
    else
      return false
    end
  end
  
  # ライブドアブログのランキングからサイトを取得する。
  # カテゴリ番号（ライブドア）とカテゴリID（articlesテーブル）を指定。
  #
  # RSSでランキングページにアクセスし、そこからURLとタイトルを抜き出す。
  # site.registered_fromは"livedoor"
  #
  # @return [Array] sites
  def get_livedoor_blogs(ld_cat_num, db_cat_id)
    feed_url = "http://blog.livedoor.com/xml/blog_ranking_cat#{ld_cat_num}.rdf"
    rss = RSS::Parser.parse(feed_url, false)
    
    sites = []
    rss.items.each_with_index  do |item, i|
      site = Site.new
      site.name = item.title
      site.url  = item.link
      site.feed_url = site.url + LIVEDOOR_RSS_SUFFIX
      site.registered_from = SITE_REG_FROM_LIVEDOOR
      site.category_id = db_cat_id
      site.rank = i + 1      
      sites.push(site)
      break if GET_COUNT_FROM_LD <= i + 1      
    end
    
    sites.each do |site|
      unless is_valid_site?(site)
        @error_message += "ライブドアブログのサイトが正常に取得できていません\n"
        Rails.logger.error("ライブドアブログのサイトが正常に取得できていません")
      end
    end
          
    return sites
  end
  
  # ライブドアブログのランキングの「サッカー」カテゴリから
  # サイトを50件取得する。
  #
  # RSSでランキングページにアクセスし、そこからURLとタイトルを抜き出す。
  # site.registered_fromは"livedoor"
  #
  # @return [Array] sites
  def get_livedoor_soccer_blogs  
    rss = RSS::Parser.parse(LD_SOCCER_FEED_URL, false)
    
    sites = []
    rss.items.each_with_index  do |item, i|
      site = Site.new
      site.name = item.title
      site.url  = item.link
      site.feed_url = site.url + LIVEDOOR_RSS_SUFFIX
      site.registered_from = SITE_REG_FROM_LIVEDOOR
      site.rank = i + 1      
      sites.push(site)
      
      break if GET_COUNT_FROM_LD <= i + 1      
    end
          
    return sites
  end
  
  # ライブドアブログのランキングの「サッカーまとめ」カテゴリから
  # サイトを50件取得する。
  #
  # RSSでランキングページにアクセスし、そこからURLとタイトルを抜き出す。
  # site.registered_fromは"livedoor"
  # site.category_idは1（2chまとめ）
  #
  # @return [Array] sites
  def get_livedoor_2ch_soccer_blogs
    rss = RSS::Parser.parse(LD_2CH_SOCCER_FEED_URL, false)
    
    sites = []
    rss.items.each_with_index  do |item, i|
      site = Site.new
      site.name = item.title
      site.url  = item.link
      site.feed_url = site.url + LIVEDOOR_RSS_SUFFIX
      site.registered_from = SITE_REG_FROM_LIVEDOOR
      site.category_id = 1
      site.rank = i + 1      
      sites.push(site)
      
      break if GET_COUNT_FROM_LD <= i + 1
    end
          
    return sites
  end
  
  # FC2ブログのランキングの「サッカー」カテゴリから
  # サイトを25件取得する
  #
  # HTTPでランキングページにアクセスし、そこからURLとタイトルを正規表現で抜き出す。
  # site.registered_fromは"fc2"
  #
  # @return [Array] sites
  def get_fc2_soccer_blogs
    uri = URI(FC2_SOCCER_URL)
    content = uri.read().toutf8

    i = 1
    sites = []
    # 正規表現で各サイトのタイトルとURLを取り出す
    content.scan(FC2_SITE_TAG_PATTERN) do |matched|
      site = Site.new
      site.url  = matched[ URI.regexp() ]
      site.name = matched[ /title="[^"]+/ ].slice(7, 99)
      site.feed_url = site.url + FC2_RSS_SUFFIX
      site.registered_from = SITE_REG_FROM_FC2
      site.rank = i
      i += 1
        
      sites.push(site)
    end
    
    sites.each do |site|
      unless is_valid_site?(site)
        @error_message += "FC2ブログのサイトが正常に取得できていません\n"
        Rails.logger.error("FC2ブログのサイトが正常に取得できていません")
      end
    end
            
    return sites
  end

# 取得できなかった時にエラーをロギングする必要あり    
   # アメーバブログのランキングの「サッカー」カテゴリからサイトを25件取得する
   #
   # HTTPでランキングページにアクセスし、そこからURLとタイトルを正規表現で抜き出す。
   # site.registered_fromは"ameba"
   #
   # @return [Array] sites
   def get_ameba_soccer_blogs
     uri = URI(AMEBA_SOCCER_URL)
     content = uri.read().toutf8

     i = 0
     sites = []
     # 正規表現で各サイトのタイトルとURLを取り出す
     content.scan(AMEBA_TAG_PATTERN) do |matched|
       break if GET_COUNT_FROM_AMEBA <= i
       
       site = Site.new
       site.url  = matched[ URI.regexp() ]
       site.name = matched[ AMEBA_NAME_PATTERN, 1 ]
       site.feed_url = site.url.sub(/ameblo.jp/, "feedblog.ameba.jp/rss/ameblo") + "rss20.xml"
       site.registered_from = SITE_REG_FROM_AMEBA
       site.rank = i + 1
       i += 1
             
       sites.push(site)
     end
     
     sites.each do |site|
       unless is_valid_site?(site)
         @error_message += "Amebaブログのサイトが正常に取得できていません\n"
         Rails.logger.error("Amebaブログのサイトが正常に取得できていません")
       end
     end
     
     return sites
   end
   
   # サイトの形式が正しいかチェック
   #
   # @return [Bool]
   def is_valid_site?(site)
     return false unless site.name 
     return false unless site.url
     return false unless site.feed_url 
     return false unless site.registered_from
     return false unless site.rank
     
     unless site.url =~ URI.regexp()
       return false
     end
     
     unless site.feed_url =~ URI.regexp()
       return false
     end
     
     return true
   end
end