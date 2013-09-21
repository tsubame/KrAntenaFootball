# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Site do
  
  subject do
    Site.new
  end

  SAMPLE_URL = "http://ja.wikipedia.org/"
  
  describe :select_by_url do
    context "sitesテーブルに同じURLのデータが登録されている" do
      before do
        site = Site.new
        site.title = "test"
        site.url = SAMPLE_URL
        site.feed_url = SAMPLE_URL
        site.save_if_not_exists
      end
      
      it "指定したURLのデータが取得できること" do
        #p Site.where(:url => SAMPLE_URL)
        site = subject.select_by_url(SAMPLE_URL)
        site.url.should == SAMPLE_URL
      end
    end

  end
  
end
