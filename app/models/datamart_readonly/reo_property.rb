class ReoProperty < DatabaseDatamartReadonly
  belongs_to :loan_general

  def self.sqlserver_create_view
    <<-eos
      SELECT
        REO_PROPERTY_id               AS id,
        loanGeneral_Id                AS loan_general_id,
        [BorrowerID]                  AS borrower_id,
        [REO_ID]                      AS reo_id,
        [LiabilityID]                 AS liability_id,
        [_MaintenanceExpenseAmount]   AS maintenance_expense_amount,
        [_CurrentResidenceIndicator]  AS current_residence_indicator,
        [_SubjectIndicator]           AS subject_indicator,
        [_LienInstallmentAmount]      AS lien_installment_amount,
        [_DispositionStatusType]      AS disposition_status_type,
        [_RentalIncomeNetAmount]      AS rental_income_net_amount,
        [_GSEPropertyType]            AS property_type
      FROM       LENDER_LOAN_SERVICE.dbo.[REO_PROPERTY]
    eos
  end

  scope :not_commercial, where{property_type != 'CommercialNonResidential'}

  def financed_property?
    return false if subject_loan?

    disposition_status_type.in?(%w(RetainForRental PendingSale RetainForPrimaryOrSecondaryResidence)) &&
        property_type.in?(%w(TwoToFourUnitProperty Cooperative SingleFamily Condominium Townhouse ManufacturedMobileHome MixedUseResidential Farm HomeAndBusinessCombined))
  end

  def subject_loan?
    subject_indicator
  end
end
