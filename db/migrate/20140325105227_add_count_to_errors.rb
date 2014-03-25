class AddCountToErrors < ActiveRecord::Migration
  def change
    add_column :site_errors, :count, :integer
  end
end
