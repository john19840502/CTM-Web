class FundingData < DatabaseDatamartReadonly
  belongs_to :loan_general

  def self.sqlserver_create_view
    <<-eos
      SELECT  FUNDING_DATA_ID AS id,
              loanGeneral_Id AS loan_general_id,
              FunderName AS funder_name
      FROM LENDER_LOAN_SERVICE.dbo.[FUNDING_DATA]
    eos
  end

end