class CreateInstitutionRegions < ActiveRecord::Migration
  def change
    create_table :institution_regions do |t|
      t.integer :region_id
      t.integer :institution_id
      t.datetime :effective_date

      t.timestamps
    end

    add_index :institution_regions, [:region_id, :institution_id, :effective_date]
  end
end
