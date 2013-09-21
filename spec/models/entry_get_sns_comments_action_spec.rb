# -*- encoding: utf-8 -*-
require 'spec_helper'

describe EntryGetSnsCommentsAction do
      
  subject do
    EntryGetSnsCommentsAction.new
  end
  
  describe :exec do
    context "entriesテーブルにエントリが複数件登録されている" do
      before do
        action = EntryFetchAction.new
        action.exec
      end
      
      it "commentsテーブルに記事が登録されていること" do
        subject.exec()
        res = Comment.all
        
        res.size.should >= 1
        puts "#{res.size}件のコメント"
        
        res.each do |c|
          p c
        end
      end
    end
  end

end
