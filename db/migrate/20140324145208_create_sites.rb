class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :domain
      t.string :name_selector
      t.string :main_image_selector
      t.string :images_selector
      t.string :button_selector

      t.timestamps
    end
  end
end
