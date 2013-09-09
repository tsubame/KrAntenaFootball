# -*- encoding: utf-8 -*-
require 'test_helper'
require 'assets/sns_count_getter'

class SnsCountGetterTest < ActiveSupport::TestCase
  
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
  INVALID_URLS_FOR_TEST = ["", nil, 33]
  
    
  def setup
    @getter = SnsCountGetter.new
    @many_random_urls = []
      
    180.times do |i| 
      @many_random_urls << "http://kuroneko.info/test#{i}"
    end
  end
  
  def teardown
    @getter = nil
  end

  
#=begin      
  # get_tw_count
  #
  test "get_tw_count 正常なURLを複数渡した場合、全て戻り値が数値である " do    
    VALID_URLS_FOR_TEST.each do |url|
      count = @getter.get_tw_count(url)
      #puts "#{url}: #{count} RT"
      assert_equal count.is_a?(Integer), true 
    end
  end
  
  test "get_tw_count 不正なURLを複数渡した場合、全て戻り値がfalseである " do    
    INVALID_URLS_FOR_TEST.each do |url|
      count = @getter.get_tw_count(url)
      assert_equal false, count
    end
    assert_equal true, @getter.error?
    assert_not_equal "", @getter.error_message
  end
  
  # get_fb_count
  #
  test "get_fb_count 正常なURLを複数渡した場合、全て戻り値が数値である " do    
    VALID_URLS_FOR_TEST.each do |url|
      count = @getter.get_fb_count(url)
      #puts "#{url}: #{count} share"
      assert_equal count.is_a?(Integer), true 
    end
  end
  
  test "get_fb_count 不正なURLを複数渡した場合、全て戻り値がfalseである " do    
    INVALID_URLS_FOR_TEST.each do |url|
      count = @getter.get_fb_count(url)
      assert_equal count, false 
    end
  end

  # get_sns_counts_parallel
  #
  test "get_sns_counts_parallel 正常なURLを複数渡した場合、正常にデータが取得でき、エラーがない " do     
    results = @getter.get_sns_counts_parallel(VALID_URLS_FOR_TEST)
    
    results.each do |url, hash|
      #puts "#{url}:"
      hash.each do |key, data|
        #puts "  #{key}: #{data}"   
        assert_equal true, data.is_a?(Integer)
      end
    end

    assert_equal false, @getter.error?
    assert_equal "", @getter.error_message
  end
  
  # exec
  #
  test "exec 正常なURLを複数渡した場合、正常にデータが取得でき、エラーがない " do
    @getter.max_thread = 3
    
    results = @getter.exec(VALID_URLS_FOR_TEST)
    results.each do |url, hash|
      puts "#{url}:"
      hash.each do |key, data|
        puts "  #{key}: #{data}"   
        assert_equal true, data.is_a?(Integer)
      end   
    end

    assert_equal false, @getter.error?
    assert_equal "", @getter.error_message
  end
#=end
    
  test "exec 200件のデータが取得でき、エラーがない" do
    @getter.max_thread = 20
    results = @getter.exec(@many_random_urls)
    results.each do |url, hash|
      puts "#{url}:"
      hash.each do |key, data|
        puts "  #{key}: #{data}"   
        assert_equal true, data.is_a?(Integer)
      end   
    end

    assert_equal false, @getter.error?
    assert_equal "", @getter.error_message
  end
  
=begin  
  # get_fb_count_parallel
  #
  test "get_fb_count_parallel 正常なURLを複数渡した場合、全て戻り値が数値である " do
    urls = VALID_URLS_FOR_TEST.each do |url|
      url
    end
     
    #counts = @getter.get_fb_count_parallel(urls)
    #puts "#{url}: #{count} share"
    #assert_equal count.is_a?(Integer), true 
  end

  # get_fb_count_parallel
  #
  #
  test "get_fb_count_parallel FC2ランキングからサイトを取得して、それらすべてのカウントが取得できるか " do
    getter = PopularBlogGetter.new
    sites = getter.get_fc2_soccer_blogs
    
    urls = []
    sites.each do |site|
      urls << site.url
    end
    counts = [] 
    #counts = @getter.get_fb_count_parallel(urls)
    counts.each do |count|
      #puts "#{url}: #{count} share"
      #assert_equal count.is_a?(Integer), true 
    end
  end
  
  # get_fb_count_parallel
  #
  #
  test "get_tw_count_parallel FC2ランキングからサイトを取得して、それらすべてのカウントが取得できるか " do
    getter = PopularBlogGetter.new
    sites = getter.get_fc2_soccer_blogs
    
    urls = []
    sites.each do |site|
      urls << site.url
    end
    counts = []
    counts = @getter.get_tw_count_parallel(urls)
    results = @getter.tw_counts_hash
    
    results.each do |key, count|
      puts "#{key}: #{count}"
    end
    
    counts.each do |count|
      #puts "#{url}: #{count} share"
      #assert_equal count.is_a?(Integer), true 
    end
  end
  
  # get_fb_count_parallel
  #
  #
  test "get_tw_count_parallel FC2ランキングからサイトを取得して、数字をURLに付け、それらすべてのカウントが取得できるか " do
    getter = PopularBlogGetter.new
    sites = getter.get_fc2_soccer_blogs
    
    urls = []
    #8.times do |i|
      sites.each do |site|
        #urls << site.url + "#{i}"
      end
    #end
    counts = []
    #counts = @getter.get_tw_count_parallel(urls)
    

    
    counts.each do |count|
      #puts "#{url}: #{count} share"
      #assert_equal count.is_a?(Integer), true 
    end
  end
=end

end
