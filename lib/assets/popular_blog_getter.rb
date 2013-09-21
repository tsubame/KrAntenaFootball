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
  
  # それぞれのランキングのページから登録する件数
  GET_COUNT = 25

  # FC2のランキングのサイトURL、タイトルが記述されてる部分の正規表現
  FC2_SITE_TAG_PATTERN = /http:..[\w\.\-\/]+?[^>]+?target[^>]+?title[^>]+?>/mi
  # アメーバサイト名、URL記述部の正規表現パターン
  AMEBA_TAG_PATTERN  = %r|<dd class="title">.+?</dd>|im
  # アメーバのサイト名の正規表現パターン
  AMEBA_NAME_PATTERN = %r|http://[\w\.\-/_=?&@:]+">([^<]+)</a|im
      
  # ライブドアブログのRSSの接尾辞（サイトのURLの後にこれが付く）
  LIVEDOOR_RSS_SUFFIX = "index.rdf"
  # FC2ブログのRSSの接尾辞（
  FC2_RSS_SUFFIX = "?xml"

  # エラーメッセージ
  attr_reader   :error_message
  # ページごとのサイトの取得件数
  attr_accessor :get_count
  
  def initialize
    @error_message = ""
    @get_count = GET_COUNT
    @rss_hash = {}
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
  # ページのフィードURLを指定。
  #
  # RSSでランキングページにアクセスし、そこからURLとタイトルを抜き出す。
  # エラー時には空の配列を返す。
  #
  # @param [String] feed_url  
  # @return [Array]  sites
  def get_livedoor_blogs(feed_url)
    return [] unless feed_url =~ URI.regexp() 
    
    begin
      rss = RSS::Parser.parse(feed_url, false)
    rescue => e
      @error_message += "ライブドアブログのフィードにアクセスできません\n"
      Rails.logger.error("ライブドアブログのフィードにアクセスできません" + e.message)
      return []
    end
    # RSSからサイトを取り出す
    sites = scan_from_livedoor_feed(rss)    
    # サイトの形式が正しいかチェック
    res = is_valid_sites?(sites, "ライブドアブログのサイトが正常に取得できていません")
    unless res
      return [] 
    end
          
    return sites
  end
  
  # FC2ブログのランキングの特定のカテゴリから、ブログサイトを複数件取得する
  #
  # HTTPでランキングページにアクセスし、そこからURLとタイトルを正規表現で抜き出す。
  # エラー時には空の配列を返す。
  #
  # @param [String] url
  # @return [Array] sites 
  def get_fc2_blogs(url) 
    return [] unless url =~ URI.regexp() 
          
    begin
      content = URI(url).read().toutf8
    rescue => e
      @error_message += "FC2ブログのページにアクセスできません\n"
      Rails.logger.error("FC2ブログのページにアクセスできません" + e.message)
      return []
    end

    sites = scan_from_fc2_html(content)        
    # サイトの形式が正しいかチェック
    res = is_valid_sites?(sites, "FC2ブログのサイトが正常に取得できていません")
    unless res
      return [] 
    end
            
    return sites
  end
 
  
  # アメーバブログのランキングのカテゴリからサイトを複数件取得する
  #
  # HTTPでランキングページにアクセスし、そこからURLとタイトルを正規表現で抜き出す。
  # site.registered_fromは"ameba"
  #
  # @return [Array] sites
  def get_ameba_blogs(url)
    return [] unless url =~ URI.regexp() 
    
    begin
      html = URI(url).read().toutf8
    rescue => e
      @error_message += "Amebaブログのページにアクセスできません\n"
      Rails.logger.error("Amebaブログのページにアクセスできません" + e.message)
      return []
    end
    
    sites = scan_from_ameba_html(html)
    # サイトの形式が正しいかチェック
    res = is_valid_sites?(sites, "Amebaブログのサイトが正常に取得できていません")
    unless res
      return [] 
    end
    
    return sites
  end
  
 
  # ライブドアのRSSフィードから
  # 各サイトのタイトルとURLを取り出す
  #
  # @param [Rss] rss
  # @return [Array] sites 
  def scan_from_livedoor_feed(rss)
    sites = []
    rss.items.each_with_index  do |item, i|
      site = Site.new
      site.title = item.title
      site.url   = item.link
      site.feed_url = site.url + LIVEDOOR_RSS_SUFFIX
      site.registered_from = "livedoor"
      site.rank = i + 1      
      sites.push(site)
      break if @get_count <= i + 1      
    end
    
    return sites
  end
  
  # FC2のページのHTMLから
  # 正規表現で各サイトのタイトルとURLを取り出す
  #
  # @param [String] html
  # @return [Array] sites 
  def scan_from_fc2_html(html)
    sites = []
    i = 1
    html.scan(FC2_SITE_TAG_PATTERN) do |matched|
      break if @get_count < i
      
      site = Site.new
      site.url   = matched[ URI.regexp() ]
      site.title = matched[ /title="[^"]+/ ].slice(7, 99)
      site.feed_url = site.url + FC2_RSS_SUFFIX
      site.registered_from = "fc2"
      site.rank = i
      sites.push(site)
      i += 1
    end
    
    return sites
  end
  
  # AmebaのページのHTMLから
  # 正規表現で各サイトのタイトルとURLを取り出す
  #
  # @param [String] html
  # @return [Array] sites 
  def scan_from_ameba_html(html)
    i = 0
    sites = []
    # 正規表現で各サイトのタイトルとURLを取り出す
    html.scan(AMEBA_TAG_PATTERN) do |matched|
      break if GET_COUNT_FROM_AMEBA <= i
      
      site = Site.new
      site.url  = matched[ URI.regexp() ]
      site.title = matched[ AMEBA_NAME_PATTERN, 1 ]
      site.feed_url = site.url.sub(/ameblo.jp/, "feedblog.ameba.jp/rss/ameblo") + "rss20.xml"
      site.registered_from = SITE_REG_FROM_AMEBA
      site.rank = i + 1
      sites.push(site)
      i += 1
    end
    
    return sites
  end
  
  # サイトの形式が正しいかチェック
  #
  # @param [Array] sites
  # @param [String] error_message
  # @return [Bool]
  def is_valid_sites?(sites, error_message)
    sites.each do |site|
      unless is_valid_site?(site)
        @error_message += error_message
        Rails.logger.error(error_message)
        
        return false
      end
    end
    
    return true
  end
  
  # サイトの形式が正しいかチェック
  #
  # @return [Bool]
  def is_valid_site?(site)
    return false unless site.title 
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
  
  # サイトの配列を受け取って、2chまとめブログがあればサブカテゴリを「2chまとめ（2）」にする
  #
  # @param  [Array] sites
  # @return [Array] sites
  def auto_categorize(sites)
    pattern = %r|201[\d]/[\d/]+[^\d]+[\d\s\.:]+ID:|i
    @max_thread = 20
    # RSSフィードを並列に取得
    req_count = 1
    sites_que = []
# RSS取得部をモジュール化      
    sites.each_with_index do |site, i|
      next if site.sub_category_id == 2
      
      sites_que << site
      if @max_thread <= sites_que.size || sites.size - 1 <= i
        puts "#{req_count}回目のアクセス"
        req_count += 1
        get_rss_of_sites_to_hash(sites_que)
        sites_que = []
      end
    end
    
    sites.each_with_index do |site, i|
      next if site.sub_category_id == 2
      
      rss = @rss_hash[site.feed_url]
      rss.items.each do |item|
        desc = item.description
        #puts desc
        if desc[pattern]
          sites[i].sub_category_id = 2
          #p site
          break
        end
      end
    end
    
    return sites
  end
  
  # RSSフィードを並列に取得し、@rss_hashに格納
  #
  # @rss_hash = {
  #   "http://~~（フィードURL）" => RSS
  # }
  #
  # @param [Array] sites
  def get_rss_of_sites_to_hash(sites) 

    ths = []
      
    sites.each do |site|
      ths << Thread.start(site) do |s|
        begin
          rss = RSS::Parser.parse(s.feed_url, false)
        rescue => e
          @error_message = 'RSSの取得に失敗しました' + e.message
          return false 
        end
        
        @rss_hash[s.feed_url] = rss
      end
    end
    
    ths.each do |th|
      th.join      
    end
  end
  
  
# 以下、削除予定  
  
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
  
  # ライブドアから登録した際のsite.registered_fromの値
  SITE_REG_FROM_LIVEDOOR = "livedoor"
  # FC2から登録した際のsite.registered_fromの値
  SITE_REG_FROM_FC2 = "fc2"
  # amebaから登録した際のsite.registered_fromの値
  SITE_REG_FROM_AMEBA = "ameba"
  
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
      site.title = item.title
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
      site.title = item.title
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
      site.title = matched[ /title="[^"]+/ ].slice(7, 99)
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
       site.title = matched[ AMEBA_NAME_PATTERN, 1 ]
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
   

end