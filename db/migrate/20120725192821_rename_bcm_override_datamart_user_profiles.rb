class RenameBcmOverrideDatamartUserProfiles < ActiveRecord::Migration
  def change
    rename_column :datamart_user_compensation_plans, :bcm_override, :bsm_override
  end
end
