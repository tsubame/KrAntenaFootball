# -*- encoding: utf-8 -*-
class Comment < ActiveRecord::Base
  # attr_accessible :title, :body
  
  # 同じURLのデータが無ければDBに保存
  # 
  # @return [bool] 保存できればtrue
  def save_if_not_exists    
    begin
      save
    rescue => e
      puts '保存に失敗しました' + e.message
      return false
    end
    
    return true 
  end
  
  # エントリに対するコメントを取得
  #
  #
  def select_by_entry_id(entry_id, count = 30)
    comments = Comment.where("entry_id" => entry_id).
      order('published desc').limit(count)
  end
  
end
