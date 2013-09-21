# -*- encoding: UTF-8 -*-
require 'open-uri'
require 'rss'
require 'assets/hatebu_entry_getter'


# はてなブックマークの人気エントリーを取得し、entriesテーブルに登録する。
# エントリーのサイトのトップページがsitesテーブルに登録されていない場合は、そのサイトも登録。
#
#
class EntryFetchAction
  
  # 記事の配列
  #attr_reader :articles
  
  def initialize
    @entries = []
  end
    
  # 処理実行 
  #
  #
  def exec
    entries = fetch_hatebu_entries
    
    site_model = Site.new
    
    entries.each do |hash|
      # サイトが登録されていなければ登録
      res = site_model.select_by_url(hash[:site][:url])
      if res == false
        site = Site.new
        site.title = hash[:site][:title]
        site.url = hash[:site][:url]
        site.save_if_not_exists
        res = site.select_by_url(hash[:site][:url])
      end
      
      entry = Entry.new
      entry.url = hash[:url]
      entry.title = hash[:title]
      entry.published = hash[:published]
      entry.category_id = hash[:category_id]
      entry.site_id = res.id
      @entries << entry
    end
    
    @entries.each do |entry|
      p entry
      res = entry.save_if_not_exists
    end
  end
  
  # はてブの人気エントリーを取得
  #
  # @return [Array] entries
  # entries = [
  #  {:title => "", :url => "", :count => 100}
  # ]
  def fetch_hatebu_entries
    # 政治、経済のエントリーを取得
    getter = HatebuEntryGetter.new
    #entries = getter.get_entries_of_categories
    entries = getter.get_entries_from_hotentry
    return entries
  end
  
end
