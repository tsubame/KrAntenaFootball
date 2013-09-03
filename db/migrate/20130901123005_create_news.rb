class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.string  :title
      t.string  :url
      t.integer :site_id
      
      t.timestamps
    end
  end
end
