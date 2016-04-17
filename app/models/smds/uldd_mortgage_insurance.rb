
#This class is basically accessors for the Mortgage Insurance (MI)
#related fields from an FHLMC, FNMA and FHLB loan.  It is not a complete model
#on its own, and should not inherit from ActiveModel.  Or, really,
#from anything.

module Smds
  class UlddMortgageInsurance
    def initialize(f_loan)
      self.loan = f_loan
    end

    def certificate_identifier
      return '' unless mortgage_insurance_relevant?
      return '' if loan.MICertNbr.nil? || loan.MICertNbr == 'NA'
      loan.MICertNbr[0..49]
    end

    def company_name
      return '' unless mortgage_insurance_relevant?
      name = (loan.MICompanyName || '').upcase
      case name
      when 'GENWORTH FINANCIAL', 'GE'
        'Genworth'
      when 'UNITED GUARANTY'
        'UGI'
      when 'ESSENT GUARANTY'
        'Essent'
      when 'RADIAN'
        'Radian'
      when 'MGIC', 'PMI', 'RMIC', 'CMG'
        name
      else
        ''
      end
    end

    def lpmi_percent
      Smds::LpmiCoveragePercentage.percent(loan.LTV, loan.LnAmortTerm)
    end

    def coverage_percent
      return '' unless mortgage_insurance_relevant?
      percent = (loan.MiCoveragePct == 0) ? lpmi_percent : loan.MiCoveragePct
      "%.4f" % percent
    end

    def coverage_percent_fnma
      return '' unless mortgage_insurance_relevant?
      percent = (loan.MiCoveragePct == 0) ? lpmi_percent : loan.MiCoveragePct
      "%.f" % percent
    end

    def lender_paid_rate_adjustment
      return '' unless mortgage_insurance_relevant?
      return '' unless loan.LenderPaidMiFlg == 'Y'

      return '' if loan.LenderMIPaidRtPct == 0
      "%.2f" % loan.LenderMIPaidRtPct
    end

    def primary_absence_reason
      return '' unless loan.LoanType == 'Conventional'
      return '' if mortgage_insurance_relevant?
      return 'Other' if relief_loan? && loan.delivery_type == 'FHLMC'
      return 'NoMIBasedOnOriginalLTV' if loan.LTV <= 80
      'MICanceledBasedOnCurrentLTV'
    end

    def primary_absence_reason_other_desc
      return '' unless primary_absence_reason == 'Other'
      'NoMIBasedOnMortgageBeingRefinanced'
    end

    def premium_financed_indicator
      return '' unless mortgage_insurance_relevant?
      (loan.FinancedMIAmt > 0).to_s
    end

    def premium_financed_amount
      return '' unless mortgage_insurance_relevant?
      return '' if loan.FinancedMIAmt == 0
      "%.2f" % loan.FinancedMIAmt
    end

    def premium_source
      return '' unless mortgage_insurance_relevant?
      return 'Lender' if loan.LenderPaidMiFlg == 'Y'
      return '' if loan.MICertNbr == 'NA'
      'Borrower'
    end

    private

    def mortgage_insurance_relevant?
      loan.loan_general.try!(:lock_loan_datum).try!(:mi_indicator)
    end

    def relief_loan?
      loan.ProductCode.include?('FR') || loan.ProductCode.include?('RP')
    end

    attr_accessor :loan
  end
end
