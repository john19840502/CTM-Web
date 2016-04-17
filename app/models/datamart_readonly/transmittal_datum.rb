class TransmittalDatum < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT
        TRANSMITTAL_DATA_id           AS id,
        loanGeneral_Id                AS loan_general_id,
        PropertyAppraisedValueAmount  AS property_appraised_value_amount,
        PropertyEstimatedValueAmount  AS property_estimated_value_amount,
        AUEngineType                  AS au_engine_type,
        AppraiserName                 AS appraiser_name,
        AppraiserCompany              AS appraiser_company,
        FieldworkObtained             AS fieldwork_obtained,
        AppraiserLicenseState         AS appraiser_license_state,
        AppraiserLicenseNumber        AS appraiser_license_number,
        LastSubmittedAURecommendation AS last_submitted_au_recommendation

      FROM       LENDER_LOAN_SERVICE.dbo.[TRANSMITTAL_DATA]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
