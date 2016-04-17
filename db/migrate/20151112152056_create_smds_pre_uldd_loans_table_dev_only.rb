class CreateSmdsPreUlddLoansTableDevOnly < ActiveRecord::Migration
  def up
    return unless Rails.env.development?
    execute <<-SQL
      CREATE TABLE [smds].[SMDSPreULDDLoans](
        [LnNbr] [varchar](50) NOT NULL
      )
    SQL
  end

  def down
    return unless Rails.env.development?
    execute <<-SQL
      DROP TABLE smds.SMDSPreULDDLoans
    SQL
  end
end
