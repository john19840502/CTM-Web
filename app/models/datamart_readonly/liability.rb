# This is the originator listed on the 1003 form for the loan.
class Liability < DatabaseDatamartReadonly

  belongs_to :loan_general

  CREATE_VIEW_SQL =  <<-eos
      SELECT    LIABILITY_id                        AS id,
                loanGeneral_id                      AS loan_general_id,
                BorrowerID                          AS borrower_id,
                [REO_ID]                            AS reo_id,
                _Type                               AS liability_type,
                _UnpaidBalanceAmount                AS unpaid_balance_amount,
                SubjectLoanResubordinationIndicator AS subject_loan_resubordination_indicator,
                HELOCMaximumBalanceAmount           AS heloc_maximum_balance_amount,
                [_MonthlyPaymentAmount]             AS monthly_payment_amount,
                [LienPosition]                      AS lien_position,
                _ExclusionIndicator                 AS exclusion_indicator,
                _HolderName                         AS holder_name,
                _PayoffStatusIndicator              AS payoff_status_indicator
      FROM      LENDER_LOAN_SERVICE.dbo.[LIABILITY]
    eos

  def self.resubordinate_mortgage_loan
    sum = 0
    where{((liability_type == 'MortgageLoan') | (liability_type == 'HELOC')) & (subject_loan_resubordination_indicator == true)}.all.each do |loan_liability|
      if loan_liability.subject_loan? && loan_liability.reo_property.try(:subject_loan?)
        sum += loan_liability.unpaid_balance_amount.to_f
      end
    end
    sum
  end

  def self.financed_properties
    where(liability_type: ['MortgageLoan', 'HELOC']).includes(:loan_general).to_a.select(&:financed_property?).map(&:reo_id).uniq.count
  end

  def financed_property?
    return false if exclusion? || paid_off? || subject_loan? || holder_title? || non_occupying_buyer?

    reo_property && reo_property.financed_property?
  end

  def holder_title?
    liability_type.in?(['MortgageLoan']) &&  !/tax|ins|t\s*&\s*i|t\s*and\s*i/.match(holder_name.downcase).nil?
  end

  def non_occupying_borrower?
    borrower && borrower.intent_to_occupy?.downcase != "yes" && liability_type == "MortgageLoan" && !borrower.occupying?
  end
 
  def borrower
    @borrower ||= loan_general.borrowers.where( :borrower_id => self.borrower_id).first
  end  

  def subject_loan?
    subject_loan_resubordination_indicator
  end

  def exclusion?
    exclusion_indicator
  end

  def paid_off?
    payoff_status_indicator
  end

  def mortgage_loan_all_unpaid
    self.mortgage_loan
  end

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def self.hi
    count
  end

  def reo_property
    loan_general.reo_properties.where(reo_id: reo_id, borrower_id: borrower_id).first
  end

  def subordinate?
    reo_property_subject_indicator   = reo_property && reo_property.subject_indicator
    subordinate_lien_amount          = loan_general.subordinate_lien_amount
    subordinate_undrawn_heloc_amount = loan_general.undrawn_heloc_amount

    if liability_type.in?(['MortgageLoan', 'HELOC']) && subject_loan_resubordination_indicator && reo_id && reo_property_subject_indicator
      "Yes"
    elsif subordinate_lien_amount.to_f > 0
      "Yes"
    elsif subordinate_undrawn_heloc_amount.to_f > 0
      "Yes"
    else
      "No"
    end
  end
end
