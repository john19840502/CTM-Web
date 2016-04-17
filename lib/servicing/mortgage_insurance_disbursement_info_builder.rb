require 'fiserv/escrow_disbursement_info'

module Servicing
  class MortgageInsuranceDisbursementInfoBuilder < DisbursementInfoBuilderBase
    attr_accessor :loan
    
    def initialize(loan, name = nil)
      self.loan = loan
    end

    def build_info
      # return lender_paid_info if loan.lender_paid_mi
      return nil if amount.zilch?

      Fiserv::EscrowDisbursementInfo.new(name).tap do |info|
        info.count = count
        info.type = type
        info.date = payment_date
        info.months = set_payment_months
        info.expiration_date = expiration_date
        info.amount = amount
        info.coverage_code = coverage_code
        info.type_qualifier = qualifier
        info.coverage_amount = coverage_amount
        info.payee_code_prefix = payee_code_prefix
        info.payee_code_suffix = payee_code_suffix
        info.certificate_identifier = certificate_identifier
      end
    end

    def set_payment_months
      return [ 0, 0, 0, 0 ] if count == 12
      return nil unless date

      return [
        disbursement.due_date.try(:to_date).try(:month) || 0,
        disbursement.second_due_date.try(:to_date).try(:month) || 0,
        disbursement.third_due_date.try(:to_date).try(:month) || 0,
        disbursement.fourth_due_date.try(:to_date).try(:month) || 0 ]
    end

    def name
      'mortgage_insurance'
    end

    def payee_code_prefix
      mortgage_insurance_payee_codes.prefix
    end

    def payee_code_suffix
      mortgage_insurance_payee_codes.suffix
    end

    def mortgage_insurance_payee_codes
      return payee_codes_from_mi_company if loan.mortgage_type == 'Conventional' || loan.lender_paid_mi
      return PayeeCode.new('0213', '56000') if loan.mortgage_type == 'FHA'
      return PayeeCode.new('0248', '00000') if loan.mortgage_type == 'FarmersHomeAdministration'
      PayeeCode.dummy
    end

    def qualifier
      case loan.mortgage_type
      when 'FarmersHomeAdministration' then '8'
      when 'FHA' then ' '
      else '0'
      end
    end

    def hud_line_num
      1003
    end

    def system_fee_name
      "Mortgage Insurance"
    end

    def escrow_item_type
      "MortgageInsurance"
    end

    def disbursement_name
      "MortgageInsurance"
    end

    # def lender_paid_info
    #   Fiserv::EscrowDisbursementInfo.new(name).tap do |db|
    #     db.count = '01'
    #     db.type = '5'
    #     db.amount = 0
    #     if loan.closing_on.present?
    #       db.date = loan.closing_on + 12.months
    #       db.months = [ loan.closing_on.month, 0, 0, 0 ]
    #     end
    #     db.type_qualifier = '1'
    #     db.certificate_identifier = loan.mi_certificate_id.present? ? loan.mi_certificate_id : '999999993'
  
    #     db.expiration_date = db.date
    #     payee_code = payee_codes_from_mi_company
    #     db.payee_code_prefix, db.payee_code_suffix = [ payee_code.prefix, payee_code.suffix ]
    #     db.coverage_amount = loan.base_loan_amount
    #     db.coverage_code = 'N'
    #     db.fha_loan = loan.is_fha?
    #   end
    # end

    def payee_codes_from_mi_company
      case loan.mi_company_id
      when 3124 then PayeeCode.new '0217'
      when 1671 then PayeeCode.new '0219'
      when 1673 then PayeeCode.new '0200'
      when 1672 then PayeeCode.new '0210'
      when 1674 then PayeeCode.new '0215'
      when 8352 then PayeeCode.new '0220'
      else PayeeCode.new '9999', '99901'
      end
    end

    def count
      super || 12
    end

    def type
      return 'R' if loan.mortgage_type == 'FHA'
      return 'P'
    end

    def coverage_code
      return 'N' if (loan.mortgage_type.eql?('Conventional') && count == 12) ||
          loan.mortgage_type.eql?('FarmersHomeAdministration') ||
          loan.lender_paid_mi
          
      return ' '
    end

    def coverage_amount
      case loan.mortgage_type
      when 'FHA'
        loan.original_balance
      when 'FarmersHomeAdministration'
        'N'
      when 'Conventional'
        loan.base_loan_amount.to_f
      else
        0
      end
    end

    def expiration_date
      return loan.fha_anniversary_date if loan.mortgage_type == 'FHA'
      loan.mi_scheduled_termination_date
    end

    def payment_date
      return loan.closing_on + 12.months if loan.closing_on.present? && loan.mortgage_type.eql?('FarmersHomeAdministration')

      dt = loan.escrows.select{ |ed| ed.item_type =~ /mortgageinsurance/i }.map(&:due_date).max
      
      return dt if loan.mortgage_type.eql?('FHA')
      
      return dt - 1.month if dt.present?    
    end

    def amount
      annual_amount = disbursement_event.try(:annual_payment_amount) || 
        mortgage_insurance_payment_amount.to_f * 12
      (annual_amount / count).round(2)
    end

    def mortgage_insurance_payment_amount
      from_hud = hud_line.try(:monthly_amount)
      from_phe = lambda { loan.proposed_housing_expenses.select{|phe| phe.housing_expense_type == 'MI' }.first.try(:payment_amount) }
      from_hud || from_phe.call
    end

    def certificate_identifier
      pref = "00" if loan.mi_company_id == 1673
      return "FR#{sanitized_agency_case_id}" if loan.mortgage_type == 'FHA'
      return loan.agency_case_identifier if loan.mortgage_type == 'FarmersHomeAdministration'
      "#{pref}#{loan.mi_certificate_id}"
    end

    def sanitized_agency_case_id
      return nil unless loan.agency_case_identifier.present?
      temp = loan.agency_case_identifier.gsub(/-/, '')  # strip hyphens
      if loan.mortgage_type == 'FHA'
        temp[9] = '' if temp.length >= 10   # remove the 10th character, which is a checksum digit I'm told
      end
      temp
    end

  end
end
