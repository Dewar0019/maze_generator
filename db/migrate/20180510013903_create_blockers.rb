class CreateBlockers < ActiveRecord::Migration[5.1]
  def change
    create_table :blockers do |t|
      t.integer :maze_id
      t.integer :x
      t.integer :y
      t.timestamps
    end
  end
end
