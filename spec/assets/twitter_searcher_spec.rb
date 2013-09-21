# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'assets/twitter_searcher'

describe TwitterSearcher do
  
  subject do
    TwitterSearcher.new
  end
 
  
  describe :search_twitter do
    context "文字列を渡した時" do
      it "戻り値の配列のサイズが0ではなく、エラーがない" do
        q = "ジュビロ"
        #res = subject.search_twitter(q)
        #res.size.should >= 1
        subject.error?.should == false
      end    
    end
    
    context "不正なURLを渡した時" do
      it "エラーがないこと" do
        q = "http://30000000022222"
        #res = subject.search_twitter(q)
        #subject.error?.should == false
      end    
    end
    
    context "文字列以外を渡した時" do
      it "戻り値がfalseであること" do        
        q = nil
        #res = subject.search_twitter(q)
        #res.should == false
        #subject.error?.should == true
        
        q = ""
        #res = subject.search_twitter(q)
        #res.should == false
        #subject.error?.should == true
      end    
    end
  end
  
  describe :search_twitter_parallel do
    context "キーワードを10個渡した時" do
      it "戻り値の配列のサイズが0ではなく、エラーがない" do   
        keywords = ["ジュビロ", "柿谷", "セレッソ", "レイソル", "田中", "TJ", "ネイマール", "大谷", "山田大記", "カカー", "ゴラッソ"]
  
        #res = subject.search_twitter_parallel(keywords)
        #res.size.should >= 1        
        subject.error?.should == false        
      end      
    end
    
    context "URLを11個渡した時" do
      it "戻り値の配列のサイズが0ではなく、エラーがない" do   
        urls = [
          "http://gendai.ismedia.jp/articles/-/37036",
          "http://japan.digitaldj-network.com/articles/18235.html",
          "http://headlines.yahoo.co.jp/hl?a=20130921-00000015-sanspo-ent",
          "http://atmatome.jp/u/vamonos_pest/3y2mv1y/",
          "http://zasshi.news.yahoo.co.jp/article?a=20130921-00000011-pseven-ent",
          "http://lifehack2ch.livedoor.biz/archives/51457477.html",
          "http://headlines.yahoo.co.jp/hl?a=20130921-00000096-spnannex-ent",
          "http://www.4gamer.net/games/234/G023417/20130921011/",
          "http://www.4gamer.net/games/233/G023374/20130921007/",
          "http://alfalfalfa.com/archives/6824587.html",
          "http://www.nikkei.com/article/DGXZZO59970440Q3A920C1000000/"
        ]  

        #res = subject.search_twitter_parallel(urls)
        #res.size.should >= 1        
        #subject.error?.should == false
      end      
    end
  end
  
  describe :search_twitter_parallel_limited do   
    context "URLを11個渡した時" do
      it "戻り値の配列のサイズが0ではなく、エラーがない" do   
        urls = [
          "http://gendai.ismedia.jp/articles/-/37036",
          "http://japan.digitaldj-network.com/articles/18235.html",
          "http://headlines.yahoo.co.jp/hl?a=20130921-00000015-sanspo-ent",
          "http://atmatome.jp/u/vamonos_pest/3y2mv1y/",
          "http://zasshi.news.yahoo.co.jp/article?a=20130921-00000011-pseven-ent",
          "http://lifehack2ch.livedoor.biz/archives/51457477.html",
          "http://headlines.yahoo.co.jp/hl?a=20130921-00000096-spnannex-ent",
          "http://www.4gamer.net/games/234/G023417/20130921011/",
          "http://www.4gamer.net/games/233/G023374/20130921007/",
          "http://alfalfalfa.com/archives/6824587.html",
          "http://www.nikkei.com/article/DGXZZO59970440Q3A920C1000000/"
        ]  
        res = {}
        #res = subject.search_twitter_parallel_limited(urls)
        #res.size.should >= 1        
        #subject.error?.should == false
        
        res.each do |key, value|
          #puts ""; puts key
          #value.each do |c|
          #  p c
          #end
        end
        
      end      
    end
  end
  
  describe :search_twitter_without_rt do   
    it "戻り値の配列のサイズが0ではなく、エラーがない" do  
      
      q = "上原"
      q = "http://headlines.yahoo.co.jp/hl?a=20130921-00000083-spnannex-base"
      res = subject.search_twitter_without_rt(q)
      subject.error?.should == false
      
      res.each do |c|
        #p c.text
      end
    end
  end
  
  describe :pickup_comment_tweets do   
    it "戻り値の配列のサイズが0ではなく、エラーがない" do  
      q = "http://headlines.yahoo.co.jp/hl?a=20130921-00000083-spnannex-base"
      q = "http://dengekionline.com/elem/000/000/715/715326/"
      q = "http://allabout.co.jp/gm/gc/428214/"
      q = "http://alfalfalfa.com/archives/6824587.html"
      res = subject.search_twitter_without_rt(q)

      comments, no_comments = subject.pickup_comment_tweets(res)
      subject.error?.should == false
      
      comments.each do |c|
        p c.text
      end
      
      puts "------------"
      
      texts = []
      no_comments.each do |c|
        texts << c.text
      end
      texts = texts.sort do |a, b|
        b.size <=> a.size
      end
      
      texts.each_with_index do |t, i|
        texts[i] = t.strip
        texts[i] = texts[i].gsub(/[　\n]+/, "")
        p t
      end
      
      puts "------------"
       
      # ツイートの件数ループ
      comments.each do |c|
        c.text = c.text.strip
        c.text = c.text.gsub(/[　\n]+/, "")
        texts.each do |str|
          c.text = c.text.sub(str, "")
        end
        c.text = c.text.strip
        c.text = c.text.gsub(/[　\n]+/, "")
        p c.text
      end
    end
  end
  
end