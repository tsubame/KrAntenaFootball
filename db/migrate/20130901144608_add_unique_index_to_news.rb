class AddUniqueIndexToNews < ActiveRecord::Migration
  def change
    add_index :news, :url, :name => "unique_url", :unique => true
  end
end
