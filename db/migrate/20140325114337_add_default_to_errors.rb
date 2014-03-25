class AddDefaultToErrors < ActiveRecord::Migration
  def change
    change_column :site_errors, :count, :integer, :default => 0
  end
end
