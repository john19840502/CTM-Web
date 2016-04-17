class ConstructionRefinanceDatum < DatabaseDatamartReadonly
  belongs_to :loan_general

  def self.sqlserver_create_view
    <<-eos
      SELECT
        CONSTRUCTION_REFINANCE_DATA_id AS id,
        loanGeneral_Id          AS loan_general_id,
        GSERefinancePurposeType   AS gse_refinance_purpose_type
      FROM       LENDER_LOAN_SERVICE.dbo.[CONSTRUCTION_REFINANCE_DATA]
    eos
  end
end
