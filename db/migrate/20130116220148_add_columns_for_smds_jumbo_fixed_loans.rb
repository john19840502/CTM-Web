class AddColumnsForSmdsJumboFixedLoans < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSJumboFixedLoans
          ADD NoteRate DECIMAL(8,4),
              SellPrice DECIMAL(15,12),
              PricingDate DATETIME,
              InvestorName VARCHAR(50)
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSJumboFixedLoans
          DROP COLUMN NoteRate,
              SellPrice,
              PricingDate,
              InvestorName
      SQL
    end
  end
end
