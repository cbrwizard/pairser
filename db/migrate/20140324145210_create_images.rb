class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :website
      t.references :good, index: true

      t.timestamps
    end
  end
end
