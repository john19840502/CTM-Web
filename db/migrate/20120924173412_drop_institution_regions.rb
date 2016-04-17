class DropInstitutionRegions < ActiveRecord::Migration
  def change
    drop_table :institution_regions
    drop_table :region_states
  end
end
