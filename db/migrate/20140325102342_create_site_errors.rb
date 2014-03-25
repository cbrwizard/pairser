class CreateSiteErrors < ActiveRecord::Migration
  def change
    create_table :site_errors do |t|
      t.string :domain

      t.timestamps
    end
  end
end
