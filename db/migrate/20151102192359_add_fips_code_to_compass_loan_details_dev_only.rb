class AddFipsCodeToCompassLoanDetailsDevOnly < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          ADD FIPSCode varchar(5),
              Brw1SelfEmpFlg varchar(1),
              Brw2SelfEmpFlg varchar(1),
              Brw3SelfEmpFlg varchar(1),
              Brw4SelfEmpFlg varchar(1)
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP COLUMN FIPSCode,
                      Brw1SelfEmpFlg,
                      Brw2SelfEmpFlg,
                      Brw3SelfEmpFlg,
                      Brw4SelfEmpFlg
      SQL
    end
  end
end
