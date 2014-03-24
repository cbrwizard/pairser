class AddGoodsToUsers < ActiveRecord::Migration
  def change
    add_column :goods, :user_id, :integer
  end
end
