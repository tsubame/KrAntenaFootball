# -*- encoding: utf-8 -*-
require 'test_helper'
require 'assets/popular_blog_getter'

class PopularBlogGetterTest < ActiveSupport::TestCase
  
  def setup
    @getter = PopularBlogGetter.new
  end
  
  def teardown
    @getter = nil
  end
 
  #
  #
  #
  test "exec 取得した配列のサイズが一定以上である" do
    res = @getter.exec
    res.each do |site|
      p site
    end
    puts "#{res.size}件"
    min_expected = 50
    assert min_expected <= res.size
  end
  
  #
  #
  #
  test "get_livedoor_soccer_blogs 取得した配列のサイズが一定以上である" do
    res = @getter.get_livedoor_soccer_blogs
    res.each do |site|
      #p site
    end
    min_expected = 20
    assert min_expected <= res.size
  end
  
  #
  #
  #
  test "get_livedoor_2ch_soccer_blogs 取得した配列のサイズが一定以上である" do
    res = @getter.get_livedoor_2ch_soccer_blogs    
    res.each do |site|
      #p site
    end
    min_expected = 20
    assert min_expected <= res.size
  end
  
  #
  #
  #
  test "get_fc2_soccer_blogs 取得した配列のサイズが25である" do
    expected = 25
    res = @getter.get_fc2_soccer_blogs

    res.each do |site|
      #p site
    end
    
    assert_equal expected, res.size
  end
  
end
