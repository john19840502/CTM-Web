class CreateStateTitleVendors < ActiveRecord::Migration
  def change
    create_table :state_title_vendors do |t|
      t.string :state
      t.integer :retail_vendor_id
      t.integer :wholesale_vendor_id
    end
  end
end
