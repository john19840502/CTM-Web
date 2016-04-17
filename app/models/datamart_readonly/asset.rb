class Asset < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT
    
        ASSET_id                                  AS id,
        loanGeneral_Id                            AS loan_general_id,
        BorrowerID                                AS borrower_id,
        _Type                                     AS asset_type,
        _CashOrMarketValueAmount                  AS cash_amount

      FROM       LENDER_LOAN_SERVICE.[dbo].[ASSET]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

    # SELECT [ASSET_id]
    #   ,[loanGeneral_Id]
    #   ,[BorrowerID]
    #   ,[_AccountIdentifier]
    #   ,[_CashOrMarketValueAmount]
    #   ,[_Type]
    #   ,[_HolderName]
    #   ,[_HolderStreetAddress]
    #   ,[_HolderCity]
    #   ,[_HolderState]
    #   ,[_HolderPostalCode]
    #   ,[AutomobileMakeDescription]
    #   ,[AutomobileModelYear]
    #   ,[LifeInsuranceFaceValueAmount]
    #   ,[OtherAssetTypeDescription]
    #   ,[StockBondMutualFundShareCount]
    #   FROM [dbo].[ASSET]
    # GO
end