class AddPayeeCodeToSmdsCompassLoanDetails < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          ADD LnAppRecdDt SMALLDATETIME,
              CondoProjStatusType VARCHAR(11),
              CondoProjAttachType VARCHAR(8),
              CondoProjDesignType VARCHAR(17),
              CondoProjUnitsSold VARCHAR(3),
              CondoProjTotalUnits VARCHAR(3),
              AttachmentType VARCHAR(12),
              ConstructionType VARCHAR(12),
              AVMModelName VARCHAR(28),
              PropertyValMethod VARCHAR(23),
              AffordableLoanFlag VARCHAR(1),
              RelocationLoanFlag VARCHAR(1),
              SharedEquityFlag VARCHAR(1),
              InvestorCollateralPrgm VARCHAR(33),
              PayeeCode VARCHAR(20),
              Brw1CreditScoreSource VARCHAR(30),
              Brw2CreditScoreSource VARCHAR(30),
              Brw1CitizenshipResidency VARCHAR(50),
              Brw2CitizenshipResidency VARCHAR(50),
              BaseLTV DECIMAL(8,4),
              CurrLTV DECIMAL(8,4),
              CurrCLTV DECIMAL(8,4),
              CurrHCLTV DECIMAL(8,4),
              AppraisalDocID VARCHAR(25),
              APR DECIMAL(8,4),
              SpecialFloodHazardArea VARCHAR(1),
              SoldScheduledBal MONEY
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP COLUMN LnAppRecdDt,
              CondoProjStatusType,
              CondoProjAttachType,
              CondoProjDesignType,
              CondoProjUnitsSold,
              CondoProjTotalUnits,
              AttachmentType,
              ConstructionType,
              AVMModelName,
              PropertyValMethod,
              AffordableLoanFlag,
              RelocationLoanFlag,
              SharedEquityFlag,
              InvestorCollateralPrgm,
              PayeeCode,
              Brw1CreditScoreSource,
              Brw2CreditScoreSource,
              Brw1CitizenshipResidency,
              Brw2CitizenshipResidency,
              BaseLTV,
              CurrLTV,
              CurrCLTV,
              CurrHCLTV,
              AppraisalDocID,
              APR,
              SpecialFloodHazardArea,
              SoldScheduledBal
      SQL
    end
  end
end
