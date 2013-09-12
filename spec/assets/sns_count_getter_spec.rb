# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'assets/sns_count_getter'

describe SnsCountGetter do
  
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
    
  subject do
    SnsCountGetter.new
  end
  
  # 適当なURLを配列に入れる
  before do
    @sample_urls_20 = []      
    20.times do |i| 
      @sample_urls_20 << "http://sample_url_#{i}"
    end
    
    @sample_urls_200 = []      
    200.times do |i| 
      @sample_urls_200 << "http://sample_url_#{i}"
    end
  end
  
  describe "get_tw_count" do
    context "正常なURLを渡した場合" do
      it "戻り値が数値であること" do
        VALID_URLS_FOR_TEST.each do |url|
          result = subject.get_tw_count(url)
          result.is_a?(Integer).should be_true
        end
      end
    end
    
    context "不正なURLを渡した場合" do
      it "戻り値がfalseであること" do
        INVALID_URLS_FOR_TEST.each do |url|
          subject.get_tw_count(url).should be_false
        end
      end
    end
  end
    
  describe "get_fb_count" do
    context "正常なURLを渡した場合" do
      it "戻り値が数値であること" do
        VALID_URLS_FOR_TEST.each do |url|
          result = subject.get_fb_count(url)
          result.is_a?(Integer).should be_true
        end
      end
    end
    
    context "不正なURLを渡した場合" do
      it "戻り値がfalseであること" do
        @sample_urls_20.each do |url|
          subject.get_fb_count(url).should be_false
        end
      end
    end
  end
  
  describe "get_sns_counts_parallel" do
    context "正常なURLを複数渡した場合" do
      it "正常にデータが取得でき、エラーがないこと" do
        results = subject.get_sns_counts_parallel(VALID_URLS_FOR_TEST)
        results.each do |url, hash|
          hash.each do |key, data|
            data.is_a?(Integer).should be_true
          end
        end
        
        subject.error?.should be_false
        subject.error_message.should == ""
      end
    end
  end
  
  describe "exec" do
    context "正常なURLを複数渡した場合" do
      it "正常にデータが取得でき、エラーがないこと" do
        results = subject.exec(VALID_URLS_FOR_TEST)
        results.each do |url, hash|
          hash.each do |key, data|
            data.is_a?(Integer).should be_true
          end
        end
        
        subject.error?.should be_false
        subject.error_message.should == ""
      end
    end
    
    context "URLを200件渡した場合" do
      it "エラーがないこと" do
        results = subject.exec(@sample_urls_200)
        results.each do |url, hash|
          hash.each do |key, data|
            #data.is_a?(Integer).should be_true
          end
        end
        subject.error?.should be_false
        subject.error_message.should == ""
      end
    end
  end
  
end
