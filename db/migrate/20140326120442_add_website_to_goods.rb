class AddWebsiteToGoods < ActiveRecord::Migration
  def change
    add_column :goods, :website, :text, :default => ""
  end
end
