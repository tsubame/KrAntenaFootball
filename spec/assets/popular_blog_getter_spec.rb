# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'assets/popular_blog_getter'
#require Rails.root.join('db', 'seeds')

describe PopularBlogGetter do
      
  subject do
    PopularBlogGetter.new
  end
  
  describe :get_livedoor_blogs do
    context "「ライブドア / 政治(総合)」のフィードURLを渡した場合" do
      it "返り値の配列の件数がsubject.get_countと同じであり、エラーがないこと" do
        feed_url = "http://blog.livedoor.com/xml/blog_ranking_cat22.rdf"
        res = subject.get_livedoor_blogs(feed_url)
        subject.error?.should be_false
        res.size.should == subject.get_count
      end
    end
    
    context "「ライブドア / サッカー」のフィードURLを渡した場合" do
      it "返り値の配列の件数がsubject.get_countと同じであり、エラーがないこと" do
        feed_url = "http://blog.livedoor.com/xml/blog_ranking_cat9.rdf"
        res = subject.get_livedoor_blogs(feed_url)
        subject.error?.should be_false
        res.size.should == subject.get_count
      end
    end
    
    context "「ライブドア / 野球まとめ」のフィードURLを渡した場合" do
      it "返り値の配列の件数がsubject.get_countと同じであり、エラーがないこと" do        
        feed_url = "http://blog.livedoor.com/xml/blog_ranking_cat8.rdf"
        res = subject.get_livedoor_blogs(feed_url)
        subject.error?.should be_false
        res.size.should == subject.get_count
      end
    end
    
    context "文字列以外を渡した場合" do
      it "返り値の配列の件数が0であること" do
        url = 11
        subject.get_livedoor_blogs(url).size.should == 0
        url = nil
        subject.get_livedoor_blogs(url).size.should == 0
        url = ""
        subject.get_livedoor_blogs(url).size.should == 0
        url = "http://kuroneko"
        subject.get_livedoor_blogs(url).size.should == 0
      end
    end
  end
  
  describe :get_fc2_blogs do
    context "「FC2 / 政治(総合)」のURLを渡した場合" do
      it "返り値の配列の件数がsubject.get_countと同じであり、エラーがないこと" do
        url = "http://blog.fc2.com/subgenre/9/"
        res = subject.get_fc2_blogs(url)
        subject.error?.should be_false
        res.size.should == subject.get_count
      end
    end
    
    context "「FC2 / 野球」のURLを渡した場合" do
      it "返り値の配列の件数がsubject.get_countと同じであり、エラーがないこと" do
        url = "http://blog.fc2.com/subgenre/249/"
        res = subject.get_fc2_blogs(url)
        subject.error?.should be_false
        res.size.should == subject.get_count
      end
    end
    
    context "文字列以外を渡した場合" do
      it "返り値の配列の件数が0であること" do
        url = 11
        subject.get_fc2_blogs(url).size.should == 0
        url = nil
        subject.get_fc2_blogs(url).size.should == 0
        url = ""
        subject.get_fc2_blogs(url).size.should == 0
        url = "http://kuroneko"
        subject.get_fc2_blogs(url).size.should == 0
      end
    end
  end
  
  describe :get_ameba_blogs do
    context "「Ameba / 政治(総合)」のURLを渡した場合" do
      it "返り値の配列の件数がsubject.get_countと同じであり、エラーがないこと" do
        url = "http://ranking.ameba.jp/gr_seiji"
        res = subject.get_ameba_blogs(url)
        subject.error?.should be_false
        res.size.should == subject.get_count
      end
    end
    
    context "「Ameba / 野球」のURLを渡した場合" do
      it "返り値の配列の件数がsubject.get_countと同じであり、エラーがないこと" do
        url = "http://ranking.ameba.jp/gr_baseball"
        res = subject.get_ameba_blogs(url)
        subject.error?.should be_false
        res.size.should == subject.get_count
      end
    end
    
    context "文字列以外を渡した場合" do
      it "返り値の配列の件数が0であること" do
        url = 11
        subject.get_ameba_blogs(url).size.should == 0
        url = nil
        subject.get_ameba_blogs(url).size.should == 0
        url = ""
        subject.get_ameba_blogs(url).size.should == 0
        url = "http://kuroneko"
        subject.get_ameba_blogs(url).size.should == 0
      end
    end
  end
  
  describe :auto_categorize do        
    context "FC2野球カテゴリのサイトを渡した場合" do
      before do
        url = "http://blog.fc2.com/subgenre/249/"
        @sites = subject.get_fc2_blogs(url)
      end
      
      it "site.sub_category_idが2のデータがあり、エラーがないこと" do
        sites = subject.auto_categorize(@sites)
        success_count = 0
        sites.each do |site|
          if site.sub_category_id == 2
            p site
            success_count += 1
          end
        end
        subject.error?.should be_false
        success_count.should > 0
      end
    end
    
    context "ライブドア / サッカーカテゴリのサイトを渡した場合" do
      before do
        feed_url = "http://blog.livedoor.com/xml/blog_ranking_cat9.rdf"
        @sites = subject.get_livedoor_blogs(feed_url)
      end
      
      it "site.sub_category_idが2のデータがあり、エラーがないこと" do
        sites = subject.auto_categorize(@sites)
        success_count = 0
        sites.each do |site|
          if site.sub_category_id == 2
            p site
            success_count += 1
          end
        end
        subject.error?.should be_false
        success_count.should > 0
      end
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
