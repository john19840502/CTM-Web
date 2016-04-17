class AddFeeCategoryToHudLine < ActiveRecord::Migration
  def up
    # this migration is for updating our development (and test) environment to match a specific
    # TRID change.  It should not be run in prod (or qa or trid_uat)
    return unless Rails.env.development?

    execute <<-SQL
        ALTER TABLE LENDER_LOAN_SERVICE.dbo.HUD_LINE
          ADD FeeCategory varchar(50)
    SQL
  end

  def down
    return unless Rails.env.development?
    execute <<-SQL
        ALTER TABLE LENDER_LOAN_SERVICE.dbo.HUD_LINE
          DROP COLUMN FeeCategory 
    SQL
  end
end
