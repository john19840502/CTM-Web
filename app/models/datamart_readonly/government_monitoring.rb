# This is the originator listed on the 1003 form for the loan.
class GovernmentMonitoring < DatabaseDatamartReadonly
  belongs_to :loan_general
  belongs_to :borrower

  CREATE_VIEW_SQL =  <<-eos
      SELECT     GOVERNMENT_MONITORING_id     AS id,
                loanGeneral_id                      AS loan_general_id,
                BorrowerID                          AS borrower_id,
                GenderType                          AS gender_type,                               --["Female", "Male", "InformationNotProvidedUnknown", "", "NotApplicable"]
                OtherRaceNationalOriginDescription  AS other_race_national_origin_description,
                RaceNationalOriginRefusalIndicator  AS race_national_origin_refusal_indicator,
                RaceNationalOriginType              AS race_national_origin_type,
                HMDAEthnicityType                   AS hmda_ethnicity_type                        -- ["InformationNotProvidedByApplicantInMailInternetOrTelephoneApplication", "HispanicOrLatino", "NotHispanicOrLatino", "", "NotApplicable"]
      FROM       LENDER_LOAN_SERVICE.dbo.[GOVERNMENT_MONITORING]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
