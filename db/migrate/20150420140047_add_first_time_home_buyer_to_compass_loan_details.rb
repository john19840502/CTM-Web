class AddFirstTimeHomeBuyerToCompassLoanDetails < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          ADD Brw1FirstTimeHomebuyer varchar(1),
              Brw2FirstTimeHomebuyer varchar(1),
              Brw3FirstTimeHomebuyer varchar(1),
              Brw4FirstTimeHomebuyer varchar(1)
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP COLUMN Brw1FirstTimeHomebuyer,
                      Brw2FirstTimeHomebuyer,
                      Brw3FirstTimeHomebuyer,
                      Brw4FirstTimeHomebuyer
      SQL
    end
  end
end
