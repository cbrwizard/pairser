class CreateParseRequests < ActiveRecord::Migration
  def change
    create_table :parse_requests do |t|
      t.string :domain
      t.integer :count

      t.timestamps
    end
  end
end
