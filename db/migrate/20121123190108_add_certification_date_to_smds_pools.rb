class AddCertificationDateToSmdsPools < ActiveRecord::Migration
  def change
    add_column :smds_pools, :certification_date, :datetime
  end
end
