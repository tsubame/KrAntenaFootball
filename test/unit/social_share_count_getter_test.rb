# -*- encoding: utf-8 -*-
require 'test_helper'
require 'assets/social_share_count_getter'
require 'assets/popular_blog_getter'

class SocialShareCountGetterTest < ActiveSupport::TestCase
  
  def setup
    @getter = SocialShareCountGetter.new
  end
  
  def teardown
    @getter = nil
  end
  
  # テスト用URL
  VALID_URLS_FOR_TEST = [
      "http://hackershigh.blog121.fc2.com/",
      "http://qiita.com/",
      "http://www.itmedia.co.jp/news/articles/1309/06/news133.html",
      "http://www.itmedia.co.jp/",
      "http://morizyun.github.io/",
      "http://sportsnavi.yahoo.co.jp",
      "http://sportsnavi.yahoo.co.jp/sports/soccer/japan/2013/columndtl/201309070001-spnavi",
      "http://number.bunshun.jp"
    ]
    
  # テスト用URL（不正なデータ）
  INVALID_URLS_FOR_TEST = [
      "http://aaadddddsssssssss",
      "htt",
      "",
      nil,
      33
    ]
=begin  
  # get_tw_rt_count
  #
  test "get_tw_rt_count 正当なURLを渡した場合、戻り値が数値である" do
    url = "http://www.apple.com/"
    count = @getter.get_tw_rt_count(url)
    assert_equal count.is_a?(Integer), true
  end

  test "get_tw_rt_count 正当なURLを複数渡した場合、全て戻り値が数値である " do    
    VALID_URLS_FOR_TEST.each do |url|
      count = @getter.get_tw_rt_count(url)
      puts "#{url}: #{count} RT"
      assert_equal count.is_a?(Integer), true 
    end
  end
  
  # get_fb_total_count
  #
  test "get_fb_total_count 正当なURLを複数渡した場合、全て戻り値が数値である " do    
    VALID_URLS_FOR_TEST.each do |url|
      count = @getter.get_fb_total_count(url)
      puts "#{url}: #{count} share"
      assert_equal count.is_a?(Integer), true 
    end
  end
  
  test "get_fb_total_count 不正なURLを複数渡した場合、全て戻り値がfalseである " do    
    INVALID_URLS_FOR_TEST.each do |url|
      count = @getter.get_fb_total_count(url)
      puts "#{url}: #{count}"
      assert_equal count, false 
    end
  end
=end

  # get_fb_total_count_parallel
  #
  test "get_fb_total_count_parallel 正当なURLを複数渡した場合、全て戻り値が数値である " do
    urls = VALID_URLS_FOR_TEST.each do |url|
      url
    end
     
    #counts = @getter.get_fb_total_count_parallel(urls)
    #puts "#{url}: #{count} share"
    #assert_equal count.is_a?(Integer), true 
  end

  # get_fb_total_count_parallel
  #
  #
  test "get_fb_total_count_parallel FC2ランキングからサイトを取得して、それらすべてのカウントが取得できるか " do
    getter = PopularBlogGetter.new
    sites = getter.get_fc2_soccer_blogs
    
    urls = []
    sites.each do |site|
      urls << site.url
    end
    counts = [] 
    #counts = @getter.get_fb_total_count_parallel(urls)
    counts.each do |count|
      #puts "#{url}: #{count} share"
      #assert_equal count.is_a?(Integer), true 
    end
  end
  
  # get_fb_total_count_parallel
  #
  #
  test "get_tw_rt_count_parallel FC2ランキングからサイトを取得して、それらすべてのカウントが取得できるか " do
    getter = PopularBlogGetter.new
    sites = getter.get_fc2_soccer_blogs
    
    urls = []
    sites.each do |site|
      urls << site.url
    end
    counts = []
    counts = @getter.get_tw_rt_count_parallel(urls)
    results = @getter.tw_counts_hash
    
    results.each do |key, count|
      puts "#{key}: #{count}"
    end
    
    counts.each do |count|
      #puts "#{url}: #{count} share"
      #assert_equal count.is_a?(Integer), true 
    end
  end
  
  # get_fb_total_count_parallel
  #
  #
  test "get_tw_rt_count_parallel FC2ランキングからサイトを取得して、数字をURLに付け、それらすべてのカウントが取得できるか " do
    getter = PopularBlogGetter.new
    sites = getter.get_fc2_soccer_blogs
    
    urls = []
    #8.times do |i|
      sites.each do |site|
        #urls << site.url + "#{i}"
      end
    #end
    counts = []
    #counts = @getter.get_tw_rt_count_parallel(urls)
    

    
    counts.each do |count|
      #puts "#{url}: #{count} share"
      #assert_equal count.is_a?(Integer), true 
    end
  end
  
end
