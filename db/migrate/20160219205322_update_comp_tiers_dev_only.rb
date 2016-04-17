class UpdateCompTiersDevOnly < ActiveRecord::Migration
  def up
    return unless Rails.env.development?
    execute <<-SQL
      sp_rename 'ctm.Comp_Tier.Effective_Date', 'Effective_In_Date', 'COLUMN'
    SQL

    execute <<-SQL
      ALTER TABLE ctm.Comp_Tier
        ADD SMDS_Product_ID int NULL,
            State_ID int NULL,
            Effective_Out_Date datetime NULL
    SQL
  end

  def down
    return unless Rails.env.development?
    execute <<-SQL
      sp_rename 'ctm.Comp_Tier.Effective_In_Date', 'Effective_Date', 'COLUMN'
    SQL

    execute <<-SQL
      ALTER TABLE ctm.Comp_Tier
        DROP COLUMN SMDS_Product_ID, State_ID, Effective_Out_Date
    SQL
  end
end
