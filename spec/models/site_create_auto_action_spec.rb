# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'assets/popular_blog_getter'
#require Rails.root.join('db', 'seeds')

describe SiteCreateAutoAction do
      
  subject do
    SiteCreateAutoAction.new
  end
  
  describe :get_blog_sites do
    it "返り値の配列の件数が100以上であること" do
      res = subject.get_blog_sites()
      #subject.error?.should be_false
      res.size.should >= 100
p res
    end
  end
  
  describe :exec do
    it "sites.allの件数が100以上であること" do
      subject.exec()
      sites = Site.all
      #subject.error?.should be_false
      sites.size.should >= 100
#p sites
    end
  end
  
=begin   

  describe :exec do
    it "取得した配列のサイズが50以上であること" do
      res = subject.exec
      res.each do |site|
        #p site
      end
      puts "#{res.size}件"
      min_expected = 50
      res.size.should >= min_expected
    end
  end
  
  describe :get_livedoor_soccer_blogs do
    it "取得した配列のサイズが20以上であること" do
      res = subject.get_livedoor_soccer_blogs
      min_expected = 20
      res.size.should >= min_expected
    end
  end
  
  describe :get_livedoor_2ch_soccer_blogs do
    it "取得した配列のサイズが20以上であること" do
      res = subject.get_livedoor_2ch_soccer_blogs
      min_expected = 20
      res.size.should >= min_expected
    end
  end
  
  describe :get_fc2_soccer_blogs do
    it "取得した配列のサイズが25であること" do
      res = subject.get_fc2_soccer_blogs
      expected = 25
      res.size.should == expected
    end
  end
  
  describe :get_ameba_soccer_blogs do
    it "取得した配列のサイズが25であること" do
      res = subject.get_ameba_soccer_blogs      
      expected = 25
      res.size.should == expected
    end
    
    it "タイトルやURLが取得できていて、エラーがないこと" do
      res = subject.get_ameba_soccer_blogs
      res.each do |site|
#p site        
        site.title.should_not be_nil
        site.url.should_not  be_nil
        site.feed_url.should_not be_nil
      end
      
      subject.error?.should be_false
    end
  end
=end 
end
