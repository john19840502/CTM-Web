class Declaration < DatabaseDatamartReadonly
  belongs_to :loan_general

  def self.sqlserver_create_view
    <<-eos
      SELECT
        [DECLARATION_id]                            AS id,
        [loanGeneral_Id]                            AS loan_general_id,
        [BorrowerID]                                AS borrower_id,
        [AlimonyChildSupportObligationIndicator]    AS alimony_child_support_obligation_indicator,
        [BankruptcyIndicator]                       AS bankruptcy_indicator,
        [BorrowedDownPaymentIndicator]              AS borrowed_down_payment_indicator,
        [CitizenshipResidencyType]                  AS citizenship_residency_type,
        [CoMakerEndorserOfNoteIndicator]            AS co_maker_endorser_of_note_indicator,
        [HomeownerPastThreeYearsType]               AS homeowner_past_three_years_type,
        [IntentToOccupyType]                        AS intent_to_occupy_type,
        [LoanForeclosureOrJudgementIndicator]       AS loan_foreclosure_or_judgement_indicator,
        [OutstandingJudgementsIndicator]            AS outstanding_judgements_indicator,
        [PartyToLawsuitIndicator]                   AS party_to_lawsuit_indicator,
        [PresentlyDelinquentIndicator]              AS presently_delinquent_indicator,
        [PriorPropertyTitleType]                    AS prior_property_title_type,
        [PriorPropertyUsageType]                    AS prior_property_usage_type,
        [PropertyForeclosedPastSevenYearsIndicator] AS property_foreclosed_past_seven_years_indicator
      FROM         LENDER_LOAN_SERVICE.dbo.DECLARATION
    eos
  end

  def self.loan_forceclosure_indicator index
    find_by(borrower_id: "BRW#{index}").try!(:loan_foreclosure_or_judgement_indicator)
  end
end
