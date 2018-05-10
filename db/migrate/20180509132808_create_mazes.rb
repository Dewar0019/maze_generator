class CreateMazes < ActiveRecord::Migration[5.1]
  def change
    create_table :mazes do |t|
      t.integer :height
      t.integer :width
      t.timestamps
    end
  end
end
