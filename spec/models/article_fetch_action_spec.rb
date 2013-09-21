# -*- encoding: utf-8 -*-
require 'spec_helper'

describe ArticleFetchAction do
      
  subject do
    ArticleFetchAction.new
  end

  describe :exec do
    context "sitesテーブルにサイトが数百件登録されている" do
      before do
        action = SiteCreateAutoAction.new
        action.get_sites_and_register
      end
      
      it "Article.allの件数が100以上であること" do
        subject.exec()
        articles = Article.all
        #subject.error?.should be_false
        articles.size.should >= 100
        puts "#{articles.size}件の記事"
      end
    end

  end

end
