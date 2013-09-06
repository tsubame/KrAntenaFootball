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
  
  # ライブドア 「サッカー」カテゴリ ブログランキングのフィードURL
  LD_SOCCER_FEED_URL = "http://blog.livedoor.com/xml/blog_ranking_cat9.rdf"
  # ライブドア 「サッカーまとめ」カテゴリ ブログランキングのフィードURL
  LD_2CH_SOCCER_FEED_URL = "http://blog.livedoor.com/xml/blog_ranking_cat446.rdf"
  # FC2「サッカー」カテゴリのページURL
  FC2_SOCCER_URL = "http://blog.fc2.com/subgenre/250/"
    
  # FC2のランキングのサイトURL、タイトルが記述されてる部分の正規表現
  FC2_SITE_TAG_PATTERN = /http:..[\w\.\-\/]+?[^>]+?target[^>]+?title[^>]+?>/mi
  
  # ライブドアブログのRSSの接尾辞（サイトのURLの後にこれが付く）
  LIVEDOOR_RSS_SUFFIX = "index.rdf"
  # FC2ブログのRSSの接尾辞（
  FC2_RSS_SUFFIX = "?xml"
  # ライブドアから登録した際のsite.registered_fromの値
  SITE_REG_FROM_LIVEDOOR = "livedoor"
  # FC2から登録した際のsite.registered_fromの値
  SITE_REG_FROM_FC2 = "fc2"

  
  # 下3つをまとめて実行
  #
  # @return [Array] sites
  def exec
    sites = []
    sites += get_livedoor_soccer_blogs
    sites += get_livedoor_2ch_soccer_blogs
    sites += get_fc2_soccer_blogs

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
            
    return sites
  end
  
end