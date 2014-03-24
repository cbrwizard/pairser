class CreateGoods < ActiveRecord::Migration
  def change
    create_table :goods do |t|
      t.string :name
      t.integer :main_image_id

      t.timestamps
    end
  end
end
