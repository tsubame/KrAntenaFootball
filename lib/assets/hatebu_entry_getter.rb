# -*- encoding: utf-8 -*-
require 'open-uri'
require 'kconv'
require 'nokogiri'

# はてなブックマークの人気エントリーを取得して配列で返す
#
#
class HatebuEntryGetter

  # エラーメッセージ
  attr_reader   :error_message
  
  HEADLINE_URL = "http://b.hatena.ne.jp/headline"
  
  CATEGORIES = { 
    "政治と経済"    => { :category_id => 1, :category_name => "economics" },
    "エンタメ"      => { :category_id => 5, :category_name => "entertainment" },
    "アニメとゲーム" => { :category_id => 6, :category_name => "game" },
  }

  def initialize
    @error_message = ""
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
  
  # CATEGORIESにあるカテゴリーのエントリーを取得して配列で返す
  # エラー時にはfalseを返す
  #
  # @return [Array] entries
  #
  # entries = [
  #   {:title => "", :url => "", site_url => "", count = 100, :tags => ["", ""]}
  # ]
  def get_entries_of_categories 
    begin
      doc = Nokogiri::HTML(open(HEADLINE_URL))
    rescue => e
      @error_message = 'HTMLの取得に失敗しました' + e.message
      return false
    end
    
    entries = []
    CATEGORIES.each do |key, hash|
      doc.css("div.#{hash[:category_name]} li.category-#{hash[:category_name]}.hb-entry-unit-with-favorites").each do |elm|      
        html = elm.inner_html
        entry = get_entry_info(html)
        entry[:category_id] = hash[:category_id]
        entries << entry
      end
    end
  
    return entries
  end

  # ホットエントリーを取得して配列で返す
  # エラー時にはfalseを返す
  #
  # @return [Array] entries
  #
  # entries = [
  #   {:title => "", :url => "", site_url => "", count = 100, :tags => ["", ""]}
  # ]
  def get_entries_from_hotentry
    entries = []
    CATEGORIES.each do |key, hash|
      url = "http://b.hatena.ne.jp/hotentry/" + hash[:category_name]
      begin
        doc = Nokogiri::HTML(open(url))
      rescue => e
        puts @error_message = 'HTMLの取得に失敗しました' + e.message
        return false
      end
      
      doc.css("li.category-#{hash[:category_name]}.hb-entry-unit-with-favorites").each do |elm|      
        html = elm.inner_html
        entries << get_entry_info_from_hotentry(html, hash[:category_id])
      end
    end

    return entries
  end
  
  # タイトル、URL、サイトURL（トップページのURL）、タグの配列を返す
  #
  # @param  [String] html
  # @return [Hash] entry
  def get_entry_info(html)
    entry = {}
    entry[:url]   = html[ URI.regexp() ]
    entry[:title] = html[ /title[\s"=]+([^"]+)/, 1]
    entry[:count] = html[ /<span>([\d]+)<.span>/i, 1].to_i
    entry[:tags]  = get_tags(html)
    entry[:published] = html[ /date.>([^<]+)/, 1]
    entry[:site]  = {}
    entry[:site][:url]   = URI.decode(html[ /entrylist.url=([^"]+)/, 1])
    entry[:site][:title] = html[ /entrylist.url=[^"]+.+title.+『([^』]+)/, 1]
      
    return entry
  end
  
  # タイトル、URL、サイトURL（トップページのURL）、タグの配列を返す
  #
  # @param  [String] html
  # @return [Hash] entry
  def get_entry_info_from_hotentry(html, cat_id)
    entry = {}
    entry[:url]   = html[ URI.regexp() ]
    entry[:title] = html[ /entry-link.+title[\s"=]+([^"]+)/, 1]
    entry[:count] = html[ /<span>([\d]+)<.span>/i, 1].to_i
    entry[:tags]  = get_tags(html)
    entry[:published] = html[ /date.>([^<]+)/, 1]
    entry[:description] = html[ /blockquote>([^<]+)/, 1]
    entry[:site]  = {}
    entry[:site][:url]   = URI.decode(html[ /entrylist.url=([^"]+)/, 1])
    entry[:site][:title] = html[ /entrylist.url=[^"]+.+title.+『([^』]+)/, 1]
    entry[:category_id] = cat_id
      
    return entry
  end
  
  # タグを取得
  #
  # @param [String] html
  # @return [Array] tags
  def get_tags(html)
    # タグを取得
    tags = []
    html.scan( /rel[^>]+tag.>([^<]+)/i) do |matches|
      matches.each do |m|
        tags << m
      end
    end
    
    return tags
  end

end