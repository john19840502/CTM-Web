class RiskAssessment < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT
    
        RISK_ASSESMENT_id                         AS id,
        loanGeneral_Id                            AS loan_general_id,
        AUSRecommendation                         AS aus_recommendation,
        AUSType                                   AS aus_type

      FROM       LENDER_LOAN_SERVICE.[dbo].[RISK_ASSESMENT]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  # SELECT [RISK_ASSESMENT_id]
  #   ,[loanGeneral_Id]
  #   ,[AUSType]
  #   ,[AUSRecommendation]
  #   ,[AUSKey]
  #   ,[LPDocClass]
  # FROM [dbo].[RISK_ASSESMENT]
  # GO
end