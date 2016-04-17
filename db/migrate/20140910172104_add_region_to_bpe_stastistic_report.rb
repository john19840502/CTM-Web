class AddRegionToBpeStastisticReport < ActiveRecord::Migration
  def change
    add_column :bpm_statistic_reports, :region, :string
  end
end
