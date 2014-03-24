class AddDefaults < ActiveRecord::Migration
  def change
    change_column :parse_requests, :count, :integer, :default => 0
  end
end
