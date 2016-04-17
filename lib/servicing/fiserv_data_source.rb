require 'fiserv/card_deck'
require 'fiserv/escrow_disbursement_info'

module Servicing
  module FiservDataSource
    # this is a DCI-style role that extends a Master::Loan for the purpose
    # of creating a Fiserv LOI export file.

    def escrow_disbursement_containers
      if self.trid_loan?
        [ HazardInsuranceDisbursementInfoBuilder.new(self),
          MortgageInsuranceDisbursementInfoBuilder.new(self),
          CityTaxDisbursementInfoBuilder.new(self),
          CountyTaxDisbursementInfoBuilder.new(self),
          VillageTaxDisbursementInfoBuilder.new(self),
          AnnualAssessmentDisbursementInfoBuilder.new(self),
          FloodInsuranceDisbursementInfoBuilder.new(self, 'Flood Insurance'),
          FloodInsuranceDisbursementInfoBuilder.new(self, 'Flood Ins. - Gap'),
          FloodInsuranceDisbursementInfoBuilder.new(self, 'Flood Ins. - Detached Structures'),
          FloodInsuranceDisbursementInfoBuilder.new(self, 'Flood Ins. - Condo'),
          FloodInsuranceDisbursementInfoBuilder.new(self, 'Flood Ins. - Condo Gap'),
          FloodInsuranceDisbursementInfoBuilder.new(self, 'Flood Ins. - 1-4 SFR'),
          EarthquakeInsuranceDisbursementInfoBuilder.new(self),
          HurricaneInsuranceDisbursementInfoBuilder.new(self),
          WindInsuranceDisbursementInfoBuilder.new(self),
          SchoolTaxDisbursementInfoBuilder.new(self),
          PropertyTaxDisbursementInfoBuilder.new(self),
          TridOtherDisbursementInfoBuilder.new(self),
        ].flat_map(&:build_info).compact
      else
        [ HazardInsuranceDisbursementInfoBuilder.new(self),
          MortgageInsuranceDisbursementInfoBuilder.new(self),
          CityTaxDisbursementInfoBuilder.new(self),
          CountyTaxDisbursementInfoBuilder.new(self),
          VillageTaxDisbursementInfoBuilder.new(self),
          AnnualAssessmentDisbursementInfoBuilder.new(self),
          FloodInsuranceDisbursementInfoBuilder.new(self, 'Flood Insurance'),
          OtherDisbursementInfoBuilder.new(self, 1008),
          OtherDisbursementInfoBuilder.new(self, 1009),
        ].flat_map(&:build_info).compact
      end
    end

    def get_refinance_indicator
      pc = Translation::LoanServProductCode.new(product_code).translate
      ['C15FF', 'C15FR', 'C15RC', 'C20FF', 'C20FR', 'C30FF', 'C30FR', 'C30RC'].include?(pc) ? 'PLS' : nil
    end

    def sanitized_agency_case_id
      return nil unless agency_case_identifier.present?
      temp = agency_case_identifier.gsub(/-/, '')  # strip hyphens
      if mortgage_type == 'FHA'
        temp[9] = '' if temp.length >= 10   # remove the 10th character, which is a checksum digit I'm told
      end
      temp
    end

    def fha_anniversary_date
      return nil unless first_payment_on.present?
      (first_payment_on + 11.months).to_date
    end

    def escrow_first_payment_date
      return nil unless first_payment_on.present?
      count_prev_pmts = lambda do
        payment_occurrences.select{|p| p.payment_received_on.present? }.count
      end
      first_payment_on + count_prev_pmts.call.months
    end

    def primary_borrower_total_monthly_income
      total_income_matching(primary_borrower) { |source| true }
    end

    def primary_borrower_income_of_type(income_type)
      total_income_matching(primary_borrower) { |source| source.income_type == income_type }
    end

    def secondary_borrower_total_monthly_income
      total_income_matching(secondary_borrower) { |source| true }
    end

    def secondary_borrower_income_of_type(income_type)
      total_income_matching(secondary_borrower) { |source| source.income_type == income_type }
    end

    def secondary_borrower_income_other
      total_income_matching(secondary_borrower) { |source| !EXPLICITLY_LISTED_INCOME_TYPES.include?(source.income_type) }
    end

    EXPLICITLY_LISTED_INCOME_TYPES = [ 'Base', 'NetRentalIncome', 'Commission', 
        'Overtime', 'Bonus', 'DividendsInterest' ]

    def primary_borrower_income_other
      total_income_matching(primary_borrower) { |source| !EXPLICITLY_LISTED_INCOME_TYPES.include?(source.income_type) }
    end

    def total_income_matching(borrower, &block)
      return nil unless borrower
      borrower.income_sources.select(&block).
        inject(0) { |sum, source| sum += source.monthly_amount }
    end

    def total_liability_amount
      liabilities.inject(0) {|sum, x| sum += x.unpaid_balance_amount || 0 }
    end

    def total_stock_value
      assets.select{ |asset| asset.asset_type =~ /stock/i }.inject(0) { |sum, x| sum += x.amount }
    end

    def total_assets_value
      assets.inject(0) { |sum, x| sum += x.amount }
    end

    def is_employee_loan?
      employee_loan_indicator
    end

    def fnma_loan?
      investor_name == 'Fannie Mae'
    end

    def fhlmc_loan?
      investor_name == 'Freddie Mac'
    end

    def number_of_bedrooms1
      investor_delivery_units.number_of_bedrooms_for(1)
    end

    def number_of_bedrooms2
      investor_delivery_units.number_of_bedrooms_for(2)
    end

    def number_of_bedrooms3
      investor_delivery_units.number_of_bedrooms_for(3)
    end

    def number_of_bedrooms4
      investor_delivery_units.number_of_bedrooms_for(4)
    end

    def eligible_rent1
      investor_delivery_units.eligible_rent_for(1)
    end

    def eligible_rent2
      investor_delivery_units.eligible_rent_for(2)
    end

    def eligible_rent3
      investor_delivery_units.eligible_rent_for(3)
    end

    def eligible_rent4
      investor_delivery_units.eligible_rent_for(4)
    end

    def special_feature_code1
      special_feature_codes.for(1)
    end

    def special_feature_code2
      special_feature_codes.for(2)
    end

    def special_feature_code3
      special_feature_codes.for(3)
    end

    def special_feature_code4
      special_feature_codes.for(4)
    end

    def special_feature_code5
      special_feature_codes.for(5)
    end

    def special_feature_code6
      special_feature_codes.for(6)
    end

    def has_subordinate_financing?
      "Yes" == (Loan.find_by_loan_num(loan_num).try(:subordinate_financing?) || "No")
    end

    STATES_PAYING_INTEREST_ON_ESCROW = ['CA', 'CT', 'IA', 'ME', 'MD', 'MA', 'NV', 'NH', 'NY', 'OR', 'RI', 'UT', 'VT', 'WI', ]

    def escrow_pays_interest?
      STATES_PAYING_INTEREST_ON_ESCROW.include?(property_state)
    end

  end
end
