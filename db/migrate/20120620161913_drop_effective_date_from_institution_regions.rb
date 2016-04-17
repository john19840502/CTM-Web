class DropEffectiveDateFromInstitutionRegions < ActiveRecord::Migration
  def up
    remove_column :institution_regions, :effective_date
  end

  def down
    add_column :institution_regions, :effective_date, :datetime
  end
end
