class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string  :name
      t.integer :dupli_count
      
      t.timestamps
    end
  end
end
