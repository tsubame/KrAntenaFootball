# -*- encoding: utf-8 -*-
require 'spec_helper'

describe EntryFetchAction do
      
  subject do
    EntryFetchAction.new
  end

  describe :fetch_hatebu_entries do      
      it "entriesの件数が1以上であること" do
        entries = subject.fetch_hatebu_entries()
        #articles = Article.all
        entries.size.should >= 1
        puts "#{entries.size}件の記事"
      end
  end
  
  describe :exec do      
      it "entriesテーブルに記事が登録されていること" do
        subject.exec()
        p entries = Entry.all
        
        entries.size.should >= 1
        puts "#{entries.size}件の記事"
        
        p sites = Site.all
        
        sites.size.should >= 1
        puts "#{sites.size}件のサイト"
      end
  end

end
