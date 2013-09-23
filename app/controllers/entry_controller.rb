# -*- encoding: utf-8 -*-
class EntryController < ApplicationController
  
  # カテゴリごとに表示する件数
  GET_COUNT_OF_CATEGORY = 30
  
  # エントリを表示
  # 
  def index
    @entries_of_category = []
    model = Entry.new
    
    # カテゴリーを取得
    @categories = Category.all
    # カテゴリーごとの記事を取得
    @categories.each do |cat|
      @entries_of_category << model.select_todays_pop_entries(cat.id, GET_COUNT_OF_CATEGORY)
    end
    
    @comments_of_entries = {}
    comment_model = Comment.new
    @entries_of_category.each do |entries|
      entries.each do |entry|
        # ハッシュにコメント取得。キーはエントリID

        comments = comment_model.select_by_entry_id(entry.id)
        #puts "#{comments.size}comments #{entry.title} "
        @comments_of_entries[entry.id] = comments
      end
    end
    
    @comments_of_entries
  end
  
  # はてなブックマークからエントリーを取得
  #
  def fetch
    action = EntryFetchAction.new
    action.exec
    index
    render "index"
  end
  
  # エントリに対するSNSのシェア数更新
  #
  def update_sns_count
    action = EntryUpdateSnsCountAction.new
    action.exec
    index
    render "index"
  end
  
  # エントリに対するSNSのコメント取得
  #
  def get_sns_comments
    action = EntryGetSnsCommentsAction.new
    action.exec
    index
    render "index"
  end
  
  def sample
    
    text = " :   天  才 17 天才過ぎるwww"
    #text = text.sub(/^[\s　:：]+/, "")
    text = text.sub(/^[　\-\s\/／\|｜：:@…\.）\)＞>＜<→"]+/, "")

    p text
    
    #array = []
    texts = ["a", "b"]
    array = texts.map do |t|
      t += ":c"
    end
    
    p array
    index
    render "index"
  end
end
