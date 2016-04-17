require 'servicing/fiserv_data_source'
require 'fiserv/card_deck'

class Servicing::CardDeckBuilder

  # loan is Master::Loan object (or one of 2 extensions)

  attr_reader :loan

  def initialize(loan)
    loan.extend Servicing::FiservDataSource
    @loan = loan
  end

  def card_deck
    card = Fiserv::CardDeck.new condo: loan.is_condo?
    card.loan_num = loan.loan_num
    card.servicer_loan_num = loan.loan_num
    card.principal_balance = loan.principal_balance
    card.loan_type = loan.loan_type_number
    card.loan_subtype = loan.is_arm? ? '8' : '0'
    card.alternative_mortgage_indicator = loan.alternative_mortgage_indicator
    card.distribution_sequence_pointer = '7'
    card.paid_to_date = paid_to_date loan
    card.note_rate = note_rate loan
    card.market_rate = note_rate loan
    card.pi_pmt = loan.principal_and_interest_payment
    card.primary_collateral_code  = '5'

    if loan.channel.eql?('P0-Private Banking Standard')
      card.investor_code = '14001'
      card.investor_block_code = '00001'
    elsif loan.is_portfolio_loan?
      card.investor_code = '11002'
      card.investor_block_code = '00001'
    else
      card.investor_code = '11001'
      card.investor_block_code = '0000' + loan.loan_num.to_s[0,1]
    end
    
    card.fiserv_phase_code = 1
    card.key_flag = 'B'
    
    set_condo_name card

    card.receipt_opt = 7
    card.investor_loan_num = loan.loan_num
    card.investor_rate = note_rate loan
    card.property_type_code = loan.property_type
    card.purpose_code = loan.purpose
    card.grace_period = grace_period
    card.pmi_case_num_prefix = loan.pmi_company_code
    card.pmi_case_num = pmi_case_num

    handle_jq_fields card

    card.mi_premium_pd_at_closing = loan.mi_premium_from_closing_amt
    card.mi_premium_amt_financed = loan.mi_and_funding_fee_financed_amount
    # card.mi_premium_expiration_date = loan.mi_scheduled_termination_date if loan.mortgage_type == 'Conventional' && loan.has_mi?
    # the above is now being set by set_mi_termination
    card.mi_premium_term = calculate_mi_premium_term
    card.closing_date = loan.closing_on
    card.refinance_date = loan.closing_on if loan.purpose_type == "Refinance"
    card.original_balance = loan.original_balance
    card.appraisal_date = loan.appraised_on
    card.appraisal_value = loan.property_appraised_amt
    card.sale_price = loan.purchase_price
    card.maturity_date = loan.mature_on
    card.year_built = loan.structure_built_year
    card.second_mortgage_code = loan.has_subordinate_financing? ? 1 : 0
    card.amortization_term = loan.amortization_term
    card.num_units = loan.number_of_units
    card.state_code = loan.state_code
    card.census_tract = loan.census_tract
    card.institution_id = loan.institution_id
    card.coupon_expiration = '00000'
    card.property_use_code = 1
    card.county_code = loan.county_code
    card.rate_term_code = loan.amortization_type == 'AdjustableRate' ? 3 : 1
    card.flood_hazard_area = loan.flood_hazard_area.to_s == '1' ? 'Y' : 'N'
    card.application_type = get_application_type loan.mortgage_type
    card.employee_loan_indicator = loan.employee_loan_indicator ? 2 : ' '
    card.branch_number = 0
    card.first_payment_on = loan.first_payment_on
    card.product_code = loan.loan_serv_product_code
    card.internal_refinance_code = loan.internal_refinance? ? 'Y' : 'N'
    card.borrower_paid_discount_points = discount_points
    card.app_received_on = application_date
    card.total_liability_amount = loan.total_liability_amount
    card.total_stock_value = loan.total_stock_value
    card.total_assets_value = loan.total_assets_value
    card.loan_application_register_cra = 'Y' if loan.product_code == 'C30FXD MCM'
    card.metro_stat_area = loan.msa_identifier

    unless loan.is_employee_loan?
      card.primary_borrower_income_base = loan.primary_borrower_income_of_type("Base")
      card.primary_borrower_income_overtime = loan.primary_borrower_income_of_type("Overtime")
      card.primary_borrower_income_commission = loan.primary_borrower_income_of_type("Commission")
      card.primary_borrower_income_bonus = loan.primary_borrower_income_of_type("Bonus")
      card.primary_borrower_income_dividend = loan.primary_borrower_income_of_type("DividendsInterest")
      card.primary_borrower_income_rental = loan.primary_borrower_income_of_type("NetRentalIncome")
      card.primary_borrower_income_other = loan.primary_borrower_income_other
      card.primary_borrower_total_income = loan.primary_borrower_total_monthly_income
      card.secondary_borrower_income_base = loan.secondary_borrower_income_of_type("Base")
      card.secondary_borrower_income_overtime = loan.secondary_borrower_income_of_type("Overtime")
      card.secondary_borrower_income_commission = loan.secondary_borrower_income_of_type("Commission")
      card.secondary_borrower_income_bonus = loan.secondary_borrower_income_of_type("Bonus")
      card.secondary_borrower_income_dividend = loan.secondary_borrower_income_of_type("DividendsInterest")
      card.secondary_borrower_income_rental = loan.secondary_borrower_income_of_type("NetRentalIncome")
      card.secondary_borrower_income_other = loan.secondary_borrower_income_other
      card.secondary_borrower_total_income = loan.secondary_borrower_total_monthly_income
    end

    populate_primary_borrower card, loan.primary_borrower
    populate_secondary_borrower card, loan.secondary_borrower
    populate_coborrowers card, loan.coborrowers

    # ctmweb-1922, 1948
    card.fico_score = loan.lowest_fico_score

    card.property_address = loan.property_address.to_s.gsub('.', '')
    card.property_state = loan.property_state
    card.property_city = loan.property_city
    card.property_postal_code = loan.property_postal_code
    card.flood_certification_identifier = loan.flood_certification_identifier
    card.flood_map_panel_number = (loan.flood_determination_nfip_map_identifier || '').gsub(' ', '')
    card.flood_community_number = loan.flood_determination_nfip_community_identifier
    card.flood_program_code = loan.flood_program_code
    card.flood_zone = loan.flood_determination_nfip_flood_zone_identifier.to_s.gsub(/(500|\*)/, ' ')
    card.flood_determination_date = loan.flood_determination_date

    store_mailing_address card

    card.legal_description = loan.legal_descriptions.select{|ld| ld.description_type == 'LongLegal'}.first.try(:text)
    if card.legal_description.blank?
      card.legal_description = "SEE EXHIBIT A ATTACHED HERETO AND BY THIS REFERENCE MADE A PART HERE OF."
    end
    card.legal_description = card.legal_description.rstrip.gsub(/[^0-9a-z '.]/i, ' ') if card.legal_description.present?

    card.points_paid_other = other_discount_points
    card.statement_frequency = loan.amortization_type == 'AdjustableRate' ? 'C' : ' '
    card.closing_interest = closing_interest
    card.escrow_balance = closing_escrow_balance
    card.closing_escrow_balance = closing_escrow_balance
    card.closing_escrow_payment,
      card.closing_escrow_payment_sign = signify closing_escrow_payment
    card.billing_method = loan.amortization_type == 'AdjustableRate' ? '1' : 'C'
    card.tax_servicer_id = 1
    card.partial_payment_code = 2
    card.servicing_purchased_flag = 'N'   # Per Don: N for originated loans, Y for TSS loans
    card.coupon_flag = 0

    set_late_charge_codes card

    card.new_construction_flag = loan.new_construction ? 'Y' : 'N'
    card.occupancy_code = occupancy_code
    card.appraisal_type = get_appraisal_type
    card.refinance_indicator = loan.get_refinance_indicator
    card.original_occupancy_code = occupancy_code
    card.original_ltv = loan.original_ltv
    if loan.mortgage_type.in? ['Conventional', 'FHA']
      card.insurance_or_guaranty_date = loan.insured_on
      card.mip_amount_financed = loan.mi_and_funding_fee_financed_amount
    end
    card.mers_min_number = loan.min_number
    card.mers_originating_org_id = loan.min_number
    card.mers_registration_date = loan.mers_registration_date
    card.mers_registration_flag = 'Y'  #hardcoded per 4352 'all loans to be assumed MERS'
    card.mers_flag_indicator = 'R'  #hardcoded per 4352 'all loans to be assumed MERS'
    card.external_refinance_code = loan.external_refinance? ? 'Y' : 'N'
    card.tax_service_type_required = set_tax_service_type_flag
    card.prepay_penalty_flag = loan.prepayment_penalty_indicator ? '1' : '0'
    card.tax_service_order_flag = 12
    card.initial_statement_indicator = 'N'
    card.annual_percentage_rate = loan.apr_rate

    set_pmi_rate card
    set_mi_termination_date card
    set_mi_premium_expiration_date card

    set_rhs_data card if loan.mortgage_type.eql?('FarmersHomeAdministration')

    card.flood_certification_company  = "FAFDS" if loan.flood_certification_company_name =~ /First American/
    card.flood_community_number_gm_29   = loan.flood_determination_nfip_community_identifier
    card.flood_zone_gm_35               = loan.flood_determination_nfip_flood_zone_identifier
    if !loan.flood_determination_nfip_flood_zone_identifier.present? || 
      (loan.flood_determination_nfip_flood_zone_identifier.present? && loan.flood_determination_nfip_flood_zone_identifier.downcase.eql?('none'))
      card.flood_loma_lomr_received = ' '
    else
      card.flood_loma_lomr_received = 'N'
    end

    card.hpml_indicator = 'Y' if hpml_value == 'Y'

    if loan.is_portfolio_loan?
      card.deferred_fee_3                 = '1'           
      card.deferred_fee_term              = loan.amortization_term
      multiplier                          = loan.trid_loan? ? 1 : -1

      amt = loan.original_deferred_fee_amount * multiplier if loan.original_deferred_fee_amount
      card.original_deferred_fee_amount_5 = amt
      card.original_deferred_fee_amount   = amt
      card.deferred_fee_control           = ''
      card.deferred_fee_29                = ''

    end

    if loan.lender_paid_mi
      card.lpmi_premium         = (loan.original_balance.to_f * loan.mi_lender_paid_rate_percent.to_f) / 100
      card.lpmi_tax_amount      = '0000000'
      card.lpmi_balance         = '0000000'   
      card.lpmi_type_flag       = 'O' 
      card.lpmi_rate_percent    = loan.lpmi_percentage.to_f.round(0)
    end

    card.write_escrow_disbursements loan.escrow_disbursement_containers

    if loan.escrow_pays_interest?
      card.escrow_interest_code = 1
      card.escrow_interest_sub_code = 1
    else
      card.escrow_precalculated_interest = -9999.999
    end

    write_fnma_block(card) if should_write_fnma?

    write_refinance_fields(card) if loan.is_refinance?

    card.mi_percentage_covered = loan.mi_coverage_percent if loan.mortgage_type == 'Conventional'
    card.user_field_43 = Translation::AuRecommendation.new(loan.last_submitted_au_recommendation).translate
    card.user_field_47 = loan.dti || '0'
    #card.user_field_51 = loan.loan_num

    handle_fha_fields card
    handle_arm_fields card

    card
  end

  def application_date
    if loan.trid_loan?
      loan.compliance_alerts.last.try(:application_date)
    else
      loan.app_received_on
    end
  end

  def set_late_charge_codes card
    if loan.property_state.eql?('MA')
      card.late_charge_assess_code  = 0
      card.late_charge_code         = 1
      card.late_charge_rate         = 3
    elsif loan.mortgage_type.in?(%w(FarmersHomeAdministration Conventional Other)) ||
          loan.mortgage_type.to_s.empty?
      card.late_charge_assess_code  = loan.property_state.in?(%w(NC CA)) ? 1 : 0 
      card.late_charge_code         = 1
      if loan.property_state.eql?('NY')
        card.late_charge_rate = 2
      elsif loan.property_state.eql?('NC')
        if loan.original_balance < 300000
          card.late_charge_rate = 4
        elsif loan.trid_loan?
          card.late_charge_rate = loan.late_charge_percentage
        else
          card.late_charge_rate = loan.late_charge_rate
        end
      else
        card.late_charge_rate         = loan.trid_loan? ? loan.late_charge_percentage : loan.late_charge_rate
      end
    elsif loan.property_state.eql?('CA') && loan.mortgage_type.eql?('VA')
      card.late_charge_assess_code  = 1
      card.late_charge_code         = 2
      card.late_charge_rate         = loan.trid_loan? ? loan.late_charge_percentage : loan.late_charge_rate
    elsif loan.property_state.eql?('CA') && loan.mortgage_type.eql?('FHA')
      card.late_charge_assess_code  = 1
      card.late_charge_code         = 1
      card.late_charge_rate         = loan.trid_loan? ? loan.late_charge_percentage : loan.late_charge_rate
    elsif loan.mortgage_type.in?(%w(FHA VA)) && loan.property_state.eql?('NC')
      card.late_charge_assess_code  = 1
      card.late_charge_code         = 2
      card.late_charge_rate         = loan.trid_loan? ? loan.late_charge_percentage : loan.late_charge_rate
    elsif loan.mortgage_type.eql?('FHA') && loan.property_state.eql?('DC')
      card.late_charge_assess_code  = 0
      card.late_charge_code         = 1
      card.late_charge_rate         = loan.trid_loan? ? loan.late_charge_percentage : loan.late_charge_rate
    elsif loan.mortgage_type.in?(%w(FHA VA))
      card.late_charge_assess_code  = 0
      card.late_charge_code         = 2
      card.late_charge_rate         = loan.trid_loan? ? loan.late_charge_percentage : loan.late_charge_rate
    end    
  end

  def set_rhs_data(card)
    state_fips    = Translation::FipsCode.new(loan.property_state).translate.to_s.rjust(2, '0')
    county_fips   = loan.county_code.to_s.rjust(3, '0')
    agency_id     = loan.sanitized_agency_case_id
    card.rhs      = "#{state_fips}#{county_fips}#{agency_id}"
  end

  def handle_jq_fields card
    dp = DownPayment.fhlbc_dpp(loan)

    return if dp.nil?
    card.jq3 = '03'
    card.jq5 = dp.amount.to_f
  end

  def handle_fha_fields card
    return unless loan.mortgage_type == 'FHA'
    card.mip_status_code = 'A'
    card.prepayment_disclosure_option_code = 'B'
    card.mip_calculation_method = 'SC'
    card.hud_base_loan_amount = loan.base_loan_amount
    card.hud_mi_term_years = begin
                               max_term_years = (loan.original_ltv || 0) > 90 ? 30 : 11
                               term_years = ( loan.term || 360 ) / 12
                               [ max_term_years, term_years].min
                             end
    card.mi_premium_pd_at_closing = loan.mi_fha_upfront_premium_amt
    if loan.first_payment_on && !loan.original_mi_period_months.zilch?
      mi_period = loan.original_mi_period_months
      card.mip_stop_date = loan.first_payment_on + mi_period.months
    end
  end

  def handle_arm_fields card
    return unless loan.amortization_type == 'AdjustableRate'

    card.arm_contract_number =  case loan.product_code 
                                  when 'C7/1ARM LIB', 'C7/1ARM LIB HIBAL', 'C7/1 ARM LIB', 'C7/1 ARM LIB HIBAL' then 624504 
                                  when 'J5/1ARM LIB', 'C5/1ARM LIB', 'C5/1ARM LIB HIBAL', 'J5/1 ARM LIB', 'C5/1 ARM LIB', 'C5/1 ARM LIB HIBAL' then 624506 
                                  when 'J7/1ARM LIB', 'J7/1 ARM LIB' then 624512 
                                  else 777777
                                end
    card.arm_margin_rate = loan.arm_margin_rate
    card.arm_floor_rate = loan.arm_floor_rate
    card.arm_ceiling_rate = loan.rate_adjustment_lifetime_cap_percent.to_f + loan.final_note_rate.to_f #loan.arm_ceiling_rate
    card.arm_original_index_rate = loan.base_index_margin
    card.arm_original_rate = loan.final_note_rate.zilch? ? loan.requested_interest_rate_percent : loan.final_note_rate
    card.arm_p_and_i_pmt = loan.proposed_housing_expenses.select{|ph| ph.housing_expense_type == 'FirstMortgagePrincipalAndInterest'}.first.try(:payment_amount)
    card.arm_amortization_term = loan.amortization_term

    if loan.first_rate_adjustment_date.present?
      card.arm_first_rate_adjustment_date = loan.first_rate_adjustment_date
      card.arm_next_rate_adjustment_date = loan.first_rate_adjustment_date + 1.month
      card.arm_next_rate_adjustment_date_hw = loan.first_rate_adjustment_date + 1.month
    end

    card.adjusted_final_note_rate = loan.first_change_cap_rate ? loan.first_change_cap_rate.to_f + loan.final_note_rate.to_f : card.arm_ceiling_rate

    card.gy3                      = 1
    card.gy4                      = 1
    card.gy19                     = 2
    card.gy20                     = 1
    card.first_payment_on_gy5     = loan.first_payment_on - 1.month if loan.first_payment_on.present?
    card.note_rate_gy12           = note_rate loan
    card.first_payment_on_gy21    = loan.first_payment_on
    card.pi_pmt_gy28              = loan.principal_and_interest_payment

    card.next_statement_date      = calculate_next_statement_date
  end

  def calculate_next_statement_date
    fpo = loan.first_payment_on
    return nil unless fpo
    year = fpo.year
    month = fpo.month
    Date.new(year, month, 15) - 1.month
  end

  def should_write_fnma?
    # we currently do not send any fnma information for originated loans, because
    # they will not have been sold (e.g. to fnma) by the time we board them.  That
    # will likely change for tss loans later.
    loan.fnma_loan? || loan.fhlmc_loan?
  end

  def write_fnma_block card
    card.number_of_borrowers = loan.borrowers.size
    card.first_time_buyer_flag = loan.first_time_homebuyer_indicator ? 'Y' : 'N'
    card.monthly_housing_expense = loan.proposed_housing_expenses.inject(0) do |sum, e|
      sum += e.payment_amount
    end

    card.total_monthly_liability = loan.liabilities.inject(0) do |sum, l|
      sum += l.monthly_payment_amount || 0
    end

    card.number_of_bedrooms1 = loan.number_of_bedrooms1
    card.number_of_bedrooms2 = loan.number_of_bedrooms2
    card.number_of_bedrooms3 = loan.number_of_bedrooms3
    card.number_of_bedrooms4 = loan.number_of_bedrooms4

    card.eligible_rent1 = loan.eligible_rent1
    card.eligible_rent2 = loan.eligible_rent2
    card.eligible_rent3 = loan.eligible_rent3
    card.eligible_rent4 = loan.eligible_rent4

    if loan.fnma_loan?
      card.fnma_special_feature_code1 = loan.special_feature_code1
      card.fnma_special_feature_code2 = loan.special_feature_code2
      card.fnma_special_feature_code3 = loan.special_feature_code3
      card.fnma_special_feature_code4 = loan.special_feature_code4
      card.fnma_special_feature_code5 = loan.special_feature_code5
      card.fnma_special_feature_code6 = loan.special_feature_code6
    elsif loan.fhlmc_loan?
      card.fhlmc_special_feature_code1 = loan.special_feature_code1
      card.fhlmc_special_feature_code2 = loan.special_feature_code2
      card.fhlmc_special_feature_code3 = loan.special_feature_code3
      card.fhlmc_special_feature_code4 = loan.special_feature_code4
      card.fhlmc_special_feature_code5 = loan.special_feature_code5
      card.fhlmc_special_feature_code6 = loan.special_feature_code6
    end


    a = loan.down_payments.first
    b = loan.down_payments.drop(1).first
    c = loan.down_payments.drop(2).first
    d = loan.down_payments.drop(3).first
    card.down_payment_source1 = translate_down_payment_source(a)
    card.down_payment_amount1 = a.try(:amount)
    card.down_payment_source2 = translate_down_payment_source(b)
    card.down_payment_amount2 = b.try(:amount)
    card.down_payment_source3 = translate_down_payment_source(c)
    card.down_payment_amount3 = c.try(:amount)
    card.down_payment_source4 = translate_down_payment_source(d)
    card.down_payment_amount4 = d.try(:amount)

    card.closing_cost_source1 = '09' if (loan.seller_paid_closing_costs_amount || 0) > 0
    card.closing_cost_source2 = '10' if (loan.estimated_closing_costs_amount || 0) > 0
    card.seller_paid_closing_costs_amount = loan.seller_paid_closing_costs_amount
    card.estimated_closing_costs_amount = loan.estimated_closing_costs_amount
    card.fnma_product_code = loan.loan_serv_product_code
    card.cltv = loan.cltv
  end

  def write_refinance_fields card
    case loan.gse_refinance_purpose_type  
      when 'CashOutDebtConsolidation'  
        card.refinance_purpose_cash     = 'C'
        card.refinance_purpose_reason   = 'D'
       when 'CashOutHomeImprovement'  
        card.refinance_purpose_cash     = 'C'
        card.refinance_purpose_reason   = 'I'
       when 'CashOutOther'  
        card.refinance_purpose_cash     = 'C'
        card.refinance_purpose_reason   = 'C'
       when 'CashOutLimited', 'ChangeInRateTerm', 'NoCashOutFHAStreamlinedRefinance', 'NoCashOutStreamlinedRefinance', 'VAStreamlinedRefinance'
        card.refinance_purpose_cash     = 'N'
        card.refinance_purpose_reason   = '.'
    end
  end

  def translate_down_payment_source(down_payment)
    return nil unless down_payment
    Translation::DownPaymentSource.new(down_payment.down_payment_type).translate
  end

  def set_tax_service_type_flag
    if loan.trid_loan?
      lines = loan.hud_lines.hud.find_all do |line|
        [ "City Taxes", "County Taxes", "Annual Assessments", "Village Taxes", "School Taxes", 
          "Property Taxes", "Other Taxes", ].include? line.system_fee_name 
      end
    else
      lines = loan.hud_lines.hud.find_all do |line| 
        line.monthly_amount.to_f > 0 &&
          (line.line_num.in?([1004, 1005, 1006]) ||
          ( 
            line.line_num.in?([1008, 1009]) && 
            line.user_defined_fee_name.try(:downcase) =~ /county_property_tax|city_property_tax|village|town|annual_assessment|sewer|monthly_pmt_county_tax|monthly_pmt_city_tax|sanitation|school|rail|parcel|tax/
          ))
      end
    end
    
    lines.any? ? 'C' : 'B'
  end

  def set_pmi_rate card
    if loan.mortgage_type == 'Conventional'
      card.pmi_rate = loan.first_mi_renewal_premium.try(:rate)
    elsif loan.mortgage_type == 'FHA'
      card.pmi_rate = loan.fha_coverage_renewal_rate
    elsif loan.mortgage_type == 'FarmersHomeAdministration'
      card.pmi_rate = 0.4
    end
  end

  def set_condo_name card
    card.condo_name = (loan.gse_property_type.try(:downcase) =~ /condo/ && !loan.project_name.nil?) ? loan.project_name.gsub("/", "") : ''
  end

  def calculate_mi_premium_term
    return loan.amortization_term unless can_calculate_mi_term?
    months_until_mi_canceled
  end

  def can_calculate_mi_term?
    return false if (loan.original_ltv || 0) <= 78

    loan.mortgage_type == 'Conventional' && loan.has_mi? &&
          loan.final_note_rate && loan.first_payment_on
  end

  def set_mi_termination_date card
    return unless can_calculate_mi_term?

    card.mi_termination_date = calculate_mi_dates(card)
  end

  def set_mi_premium_expiration_date card
    return unless can_calculate_mi_term?

    card.mi_premium_expiration_date = calculate_mi_dates(card)
  end

  def calculate_mi_dates card
    return (loan.first_payment_on + months_until_mi_canceled.months)
  end

  def months_until_mi_canceled
    @months_until_mi_canceled ||=
      begin
        monthly_interest = loan.final_note_rate.to_f / 1200.0
        principal = [ loan.purchase_price, loan.property_appraised_amt ].reject(&:blank?).min.to_f
        payment = loan.principal_and_interest_payment.to_f
        months_to_pay_off_last_78pct =
          (Math.log(payment) - Math.log(payment - principal * 0.78 * monthly_interest)) /
          Math.log(1 + monthly_interest)
        loan.amortization_term - months_to_pay_off_last_78pct.floor - 1
      end
  end

  def hpml_value
    if loan.channel == 'R0-Reimbursement Standard'
      loan.custom_fields.where(attribute_unique_name: 'HPML').any? { |f| f.attribute_value == 'Yes' } ? 'Y' : 'N'
    else
      (loan.is_primary_residence? && HpmlResult.for(loan)) ? 'Y' : 'N'
    end
  end

  def pmi_case_num
    return loan.sanitized_agency_case_id if loan.mortgage_type.in?(%w(FHA VA FarmersHomeAdministration))
    return loan.mi_certificate_id if loan.mi_certificate_id.present? && loan.has_mi?
    nil
  end

  def occupancy_code
    return 2 if loan.property_usage_type == 'Investor'
    return 1 if ['PrimaryResidence', 'SecondHome'].include? loan.property_usage_type
    nil
  end

  def store_mailing_address card
    residence = loan.primary_borrower.try(:residence)
    mail_to   = loan.primary_borrower.try(:mail_to)

    if loan.is_primary_residence_and_purchase? && loan.property_address.present?
      # use loan.property_address
      card.mailing_address     = loan.property_address
      card.mailing_state       = loan.property_state
      card.mailing_city        = loan.property_city
      card.mailing_postal_code = loan.property_postal_code
    elsif loan.is_primary_residence? && loan.is_refinance? && (mail_to.try(:full_address).present? || loan.property_address.present?)
      # use mail_to || loan.property_address
      card.mailing_address     = mail_to.try(:full_address).present? ? "#{format_address(mail_to.street_address)}, #{format_address(mail_to.street_address_2)}"  : loan.property_address
      card.mailing_state       = mail_to.try(:full_address).present? ? mail_to.state         : loan.property_state
      card.mailing_city        = mail_to.try(:full_address).present? ? mail_to.city          : loan.property_city
      card.mailing_postal_code = mail_to.try(:full_address).present? ? mail_to.postal_code   : loan.property_postal_code
    elsif !loan.is_primary_residence? && (mail_to.try(:full_address).present? || residence.try(:address).present?)
      # mail_to || residence.address
      card.mailing_address      = mail_to.try(:full_address).present? ? "#{format_address(mail_to.street_address)}, #{format_address(mail_to.street_address_2)}"  : residence.address
      card.mailing_state        = mail_to.try(:full_address).present? ? mail_to.state         : residence.state
      card.mailing_city         = mail_to.try(:full_address).present? ? mail_to.city          : residence.city
      postal_code               = mail_to.try(:full_address).present? ? mail_to.postal_code   : residence.postal_code
      country                   = mail_to.try(:full_address).present? ? mail_to.country       : residence.country
      card.mailing_postal_code  = postal_code

      card.foreign_address_flag = is_foreign?(country) ? 'Y' : 'N'
      set_hp_and_hq_cards(card) if card.foreign_address_flag.eql?('Y')

      card.distribution_mail_code = is_foreign?(country) ? 1 : 0
    end

    card.mailing_address        = format_address(card.mailing_address)  if card.mailing_address.present?
    card.mailing_state          = card.mailing_state.upcase    if card.mailing_state.present?
    card.mailing_city           = card.mailing_city.upcase     if card.mailing_city.present?
  end

  def is_foreign?(country)
    return false if !country.present? || country.downcase =~ /us|usa|(united states)/
    true
  end

  def set_hp_and_hq_cards card
    card.primary_borrower_id_number                       = '000000000000001'
    card.primary_borrower_home_telephone_country_code     = '001'
    card.primary_borrower_work_telephone_country_code     = '001'
    
    card.primary_borrower_home_telephone_number           = loan.primary_borrower.home_phone_num
    card.primary_borrower_work_telephone_number           = loan.primary_borrower.employer.try(:phone_num)
    
    card.primary_borrower_country_code                    = Translation::CountryCode.new(loan.primary_borrower.try(:mail_to).country).translate
    card.country_code_of_property                         = 'USA'
  end 
  
  def set_hr_and_hs_cards card  
    card.secondary_borrower_id_number                     = '000000000000002'
    card.secondary_borrower_home_telephone_country_code   = '001'
    card.secondary_borrower_work_telephone_country_code   = '001'
  
    card.secondary_borrower_home_telephone_number         = loan.secondary_borrower.home_phone_num
    card.secondary_borrower_work_telephone_number         = loan.secondary_borrower.employer.try(:phone_num)
  
    card.secondary_borrower_country_code                  = Translation::CountryCode.new(loan.secondary_borrower.try(:mail_to).country).translate
  end

  def closing_escrow_payment
    non_mi_payments = loan.escrow_waiver_indicator ? 0 : calculate_closing_escrow_payment
    mi_payments     = mortgage_insurance_amount(:monthly_amount)

    non_mi_payments + mi_payments
  end

  def calculate_closing_escrow_payment
    if loan.trid_loan?
      lines = loan.hud_lines.hud.find_all do |line| 
        line.fee_category == "InitialEscrowPaymentAtClosing" && line.net_fee_indicator && line.system_fee_name != 'Mortgage Insurance'
      end
    else
      lines = loan.hud_lines.hud.find_all { |line| (1002..1009).include? line.line_num }
    end
    lines.inject(0) { |sum, line| sum += line.monthly_amount || 0 }
  end

  def escrow_aggregate_accounting_adjustment_amount
    loan.trid_loan? ? loan.escrow_aggregate_accounting_adjustment_amount.to_f : loan.hud_lines.hud.find_all{ |line| line.line_num == 1010}.try(:first).try(:total_amount).to_f
  end

  def closing_escrow_balance
    non_mi_payments = loan.escrow_waiver_indicator ? 0 : calculate_closing_escrow_balance
    other_payments  = escrow_aggregate_accounting_adjustment_amount + mortgage_insurance_amount(:total_amount)

    non_mi_payments + other_payments
  end

  def calculate_closing_escrow_balance
    if loan.trid_loan?
      lines = loan.hud_lines.hud.find_all do |line|
        line.fee_category == "InitialEscrowPaymentAtClosing" && line.net_fee_indicator && line.system_fee_name != 'Mortgage Insurance'
      end
    else
      lines = loan.hud_lines.hud.find_all { |line| (1002..1009).include? line.line_num }
    end
    lines.inject(0) { |sum, line| sum += line.total_amount || 0 }
  end

  def mortgage_insurance_amount(column = :total_amount)
    lines = loan.hud_lines.hud.find_all do |line|
      line.system_fee_name == 'Mortgage Insurance'
    end

    lines.inject(0) { |sum, line| sum += line.try(column).to_f || 0 }
  end

  def closing_interest
    return 0 if loan.channel == Channel.mini_corr.identifier
    if loan.trid_loan?
      loan.hud_lines.hud.find_all{|line| line.system_fee_name == "Prepaid Interest"}.
        inject(0) {|sum, line| sum + line.total_amount.to_f }
    else
      loan.hud_lines.hud.find{|line| line.line_num == 901}.try(:total_amount)
    end
  end

  def grace_period
    if (loan.channel && loan.channel.starts_with?('R0'))
      return 15
    else
      if loan.trid_loan?
        return loan.trid_grace_period
      else
        return loan.grace_period
      end
    end
  end

  def populate_primary_borrower card, pb
    return unless pb
    card.primary_borrower_name = borrower_name pb
    card.primary_ssn = pb.ssn
    card.primary_home_phone = format_phone pb.home_phone_num
    card.primary_work_phone = format_phone pb.employer.try(:phone_num)
    card.primary_age_years = pb.age_at_application
    card.primary_marital_status = loan.primary_marital_status
    card.primary_race = loan.primary_race
    card.primary_gender = loan.primary_gender
    card.primary_ethnicity = loan.primary_ethnicity
    card.primary_borrower_birth_date = pb.birth_date
    card.primary_borrower_us_citizen_flag = pb.citizenship_type == "USCitizen" ? 'Y' : 'N'
    card.primary_borrower_years_of_school = pb.schooling_years
    card.primary_immigration_status = immigration_status_code(pb)

    unless pb.credit_score.zilch?
      card.credit_score_1_value = pb.credit_score
      card.credit_score_1_label = "Primary borrower credit score"
    end

    employer_fields = lambda do
      employer = pb.employer
      return unless employer
      card.primary_borrower_employer_name = employer.name
      card.primary_borrower_position = employer.position
      card.primary_borrower_years_at_position = employer.years_at_position
      card.primary_borrower_months_at_position = employer.months_at_position
      card.primary_borrower_years_in_profession = employer.years_in_profession
      card.primary_borrower_self_employed = employer.self_employment_flag ? 'Y' : 'N'
    end
    employer_fields.call
  end

  def populate_secondary_borrower card, sb
    return unless sb
    card.secondary_borrower_name = borrower_name sb
    card.secondary_ssn = sb.ssn
    card.secondary_home_phone = format_phone sb.home_phone_num
    card.secondary_work_phone = format_phone sb.employer.try(:phone_num)
    card.secondary_age_years = sb.age_at_application
    card.secondary_marital_status = loan.secondary_marital_status
    card.secondary_race = loan.secondary_race
    card.secondary_gender = loan.secondary_gender
    card.secondary_ethnicity = loan.secondary_ethnicity
    card.secondary_borrower_birth_date = sb.birth_date
    card.secondary_borrower_us_citizen_flag = sb.citizenship_type == "USCitizen" ? 'Y' : 'N'
    card.secondary_borrower_years_of_school = sb.schooling_years
    card.secondary_immigration_status = immigration_status_code(sb)

    if sb.residence.present?
      residence = sb.residence
      mail_to   = loan.secondary_borrower.try(:mail_to)

      if loan.is_primary_residence? && (loan.is_purchase? || loan.is_refinance?)
        if sb.intent_to_occupy_type.eql?('Yes') && loan.property_address.present?
          # use property address
          card.secondary_borrower_mailing_address   = loan.property_address
          card.secondary_borrower_mailing_city      = loan.property_city
          card.secondary_borrower_mailing_state     = loan.property_state
          card.secondary_borrower_mailing_zip_code  = loan.property_postal_code
        elsif mail_to.try(:street_address).present? || residence.try(:address).present?
          # use mail_to address || residence
          card.secondary_borrower_mailing_address   = mail_to.try(:street_address).present? ? mail_to.street_address   : residence.address
          card.secondary_borrower_mailing_address_2 = mail_to.try(:street_address).present? ? mail_to.street_address_2 : nil
          card.secondary_borrower_mailing_city      = mail_to.try(:street_address).present? ? mail_to.city             : residence.city
          card.secondary_borrower_mailing_state     = mail_to.try(:street_address).present? ? mail_to.state            : residence.state
          card.secondary_borrower_mailing_zip_code  = mail_to.try(:street_address).present? ? mail_to.postal_code      : residence.postal_code
        end
      elsif mail_to.try(:street_address).present? || residence.try(:address).present?
        # use mail_to address || residence
        card.secondary_borrower_mailing_address   = mail_to.try(:street_address).present? ? mail_to.street_address   : residence.address
        card.secondary_borrower_mailing_address_2 = mail_to.try(:street_address).present? ? mail_to.street_address_2 : nil
        card.secondary_borrower_mailing_city      = mail_to.try(:street_address).present? ? mail_to.city             : residence.city
        card.secondary_borrower_mailing_state     = mail_to.try(:street_address).present? ? mail_to.state            : residence.state
        card.secondary_borrower_mailing_zip_code  = mail_to.try(:street_address).present? ? mail_to.postal_code      : residence.postal_code
        country                                   = mail_to.try(:street_address).present? ? mail_to.country          : residence.country
      end

      card.secondary_borrower_mailing_address   = format_address(card.secondary_borrower_mailing_address)   if card.secondary_borrower_mailing_address.present?
      card.secondary_borrower_mailing_address_2 = format_address_2(card.secondary_borrower_mailing_address_2) if card.secondary_borrower_mailing_address_2.present?
      card.secondary_borrower_mailing_city      = card.secondary_borrower_mailing_city.upcase      if card.secondary_borrower_mailing_city.present?
      card.secondary_borrower_mailing_state     = card.secondary_borrower_mailing_state.upcase     if card.secondary_borrower_mailing_state.present?
      card.secondary_foreign_address_flag       = is_foreign?(country) ? 'Y' : 'N'

      set_hr_and_hs_cards(card) if card.secondary_foreign_address_flag.eql?('Y')

    end

    unless sb.credit_score.zilch?
      card.credit_score_2_value = sb.credit_score
      card.credit_score_2_label = "Secondary borrower creditscore"
    end

    employer_fields = lambda do
      employer = sb.employer
      return unless employer
      card.secondary_borrower_employer_name = employer.name
      card.secondary_borrower_position = employer.position
      card.secondary_borrower_years_at_position = employer.years_at_position
      card.secondary_borrower_months_at_position = employer.months_at_position
      card.secondary_borrower_years_in_profession = employer.years_in_profession
      card.secondary_borrower_self_employed = employer.self_employment_flag ? 'Y' : 'N'
    end
    employer_fields.call
  end

  def populate_coborrowers card, coborrowers
    
    ht_cards = []

    (1..10).to_a.each do |brw|
      # set variables for each and assign them in the builder.
      borrower = coborrowers.shift rescue nil

      if borrower.present?
        card.send("coborrower_name_#{brw}=", borrower_name(borrower))

        ssn = borrower.ssn.present? ? borrower.ssn.to_s.gsub(/\D/, '') : nil
        phone = borrower.home_phone_num.present? ? borrower.home_phone_num : nil
        area_phone = phone.present? ? '001' : nil

        card.send("coborrower_ssn_#{brw}=", ssn) if ssn.present?
        card.send("coborrower_phone_#{brw}=", format_phone(phone)) if phone.present?

        ht_cards << Fiserv::CoborrowerInfo.new(brw.to_s.rjust(15,'0'), area_phone, phone)
  
        if borrower.residence.present?
          residence = borrower.residence
          mail_to   = borrower.try(:mail_to)

          street, street_2, city, state, zip = '','','','',''

          if loan.is_primary_residence? && (loan.is_purchase? || loan.is_refinance?)
            if borrower.intent_to_occupy_type.eql?('Yes')
              # use property address
              street    = loan.property_address
              city      = loan.property_city
              state     = loan.property_state
              zip       = loan.property_postal_code
            else
              # use mail_to address || residence
              street    = mail_to.try(:street_address).present? ? mail_to.street_address   : residence.address
              street_2  = mail_to.try(:street_address).present? ? mail_to.street_address_2 : nil
              city      = mail_to.try(:street_address).present? ? mail_to.city             : residence.city
              state     = mail_to.try(:street_address).present? ? mail_to.state            : residence.state
              zip       = mail_to.try(:street_address).present? ? mail_to.postal_code      : residence.postal_code
            end
          else
            # use mail_to address || residence
            street    = mail_to.try(:street_address).present? ? mail_to.street_address   : residence.address
            street_2  = mail_to.try(:street_address).present? ? mail_to.street_address_2 : nil
            city      = mail_to.try(:street_address).present? ? mail_to.city             : residence.city
            state     = mail_to.try(:street_address).present? ? mail_to.state            : residence.state
            zip       = mail_to.try(:street_address).present? ? mail_to.postal_code      : residence.postal_code
          end

          if street.present?
            card.send("coborrower_mailing_address_#{brw}=",   (format_address(street) if street.present?))
            card.send("coborrower_mailing_address_#{brw}_2=", (format_address_2(street_2) if street_2.present?))
            card.send("coborrower_mailing_city_#{brw}=",      (city.upcase if city.present?))
            card.send("coborrower_mailing_state_#{brw}=",     state)
            card.send("coborrower_mailing_zip_code_#{brw}=",  format_coborrower_zip(zip))
          end
        end
      end
    end

    card.write_coborrower_data ht_cards
  end

  def immigration_status_code borrower
    return nil unless borrower
    return '00' if borrower.is_us_citizen?
    return '01' if borrower.is_permanent_resident?
    '02'
  end

  def format_address(str)
    str.strip.upcase.
      gsub(/[^a-zA-Z0-9\-#&\s]/, '').
      gsub('.', '').
      gsub('APARTMENTS','ZAPTZ').gsub('APARTMENT','APT').gsub('ZAPTZ', 'APARTMENTS').
      gsub('SUITES','ZSTEZ').gsub('SUITE','STE').gsub('ZSTEZ', 'SUITES').
      sub(/AVENUE$/, 'AVE').
      sub(/BOULEVARD$/, 'BLVD').
      sub(/CIRCLE$/, 'CIR').
      sub(/COURT$/, 'CT').
      sub(/CROSSING$/, 'XING').
      sub(/DRIVE$/, 'DR').
      sub(/HIGHWAY$/, 'HWY').
      sub(/LANE$/, 'LN').
      sub(/PARKWAY$/, 'PKWY').
      sub(/PLACE$/, 'PL').
      sub(/ROAD$/, 'RD').
      sub(/ROUTE$/, 'RTE').
      sub(/STREET$/, 'ST').
      sub(/TERRACE$/, 'TER').
      sub(/TRAIL$/, 'TRL')
  end

  def format_address_2(str)
    str.strip.upcase.
          gsub('APARTMENTS','ZAPTZ').gsub('APARTMENT','APT').gsub('ZAPTZ', 'APARTMENTS').
          gsub('SUITES','ZSTEZ').gsub('SUITE','STE').gsub('ZSTEZ', 'SUITES')
  end

  def format_phone number
    return nil unless number
    return '1' + number if number.length == 10
  end

  def format_coborrower_zip zip
    if /^\d{5}/.match(zip)
      zp = zip.gsub("-", "").gsub(/\s+/, "")
      zp = zip[0..4]
      zp << "-#{zip[5..9]}" if zip.length > 5
      return zp
    end
    zip
  end

  def borrower_name borrower
    return '' unless borrower
    [name_remove_extra(borrower.first_name), name_remove_extra(borrower.middle_name), name_remove_extra(borrower.last_name), name_remove_extra(borrower.suffix)].compact.join ' '
  end

  def name_remove_extra(name)
    return nil if name.nil?
    name = name.gsub(/[^a-zA-Z\s\-\']+/, '').gsub(/\s{2,}/, ' ').strip()
    name.presence
  end

  def discount_points
    return 0 unless ['PrimaryResidence', 'SecondHome'].include? loan.property_usage_type
    return 0 unless loan.institution_id == '00098'
    return 0 unless loan.purpose_type == 'Purchase'
    loan.borrower_paid_discount_points
  end

  def other_discount_points
    return 0 unless ['PrimaryResidence', 'SecondHome'].include? loan.property_usage_type
    return 0 unless loan.institution_id == '00098'
    return 0 unless loan.purpose_type == 'Refinance'
    loan.borrower_paid_discount_points
  end

  def get_application_type mortgage_type
    return 2 if mortgage_type == 'FHA'
    return 3 if mortgage_type == 'VA'
    return 4 if mortgage_type == 'FarmersHomeAdministration'
    1
  end

  def get_appraisal_type
    case loan.fieldwork_obtained
     when /Form 1004 appraisal with interior\/exterior inspection/ then '00'
     when /Form 1004C, Manufactured Home Appraisal Report with interior\/exterior inspection/ then '00'
     when /Form 1004D appraisal updated\/completion report/ then '00'
     when /Form 1025 appraisal with interior\/exterior inspection/ then '00'
     when /Form 1073 condominium appraisal with interior\/exterior inspection/ then '00'
     when /Form 1075 condominium appraisal with exterior inspection/ then '07'
     when /Form 2000 field review one-unit/ then '09'
     when /Form 2000A field review 2-4/ then '09'
     when /Form 2055 appraisal with exterior only inspection/ then '07'
     when /Form 2075 exterior inspection/ then '07'
     when /Form 2090 cooperative appraisal with interior\/exterior inspection/ then '00'
     when /Form 2095 cooperative appraisal with exterior only inspection/ then '07'
     when /Form 26-1805, Certificate of Reasonable Value for VA/ then '09'
     when /Form 26-8712, Manufactured Home Appraisal Report for VA/ then '09'
     when /No appraisal\/inspection obtained/ then '05'
     when /Other/ then '09'
     when /Prior appraisal used for the transaction/ then '08'
     else '99'
    end
  end

  def note_rate loan
    fr = loan.final_note_rate.presence || 0
    fr > 0 ? fr : loan.requested_interest_rate_percent
  end

  def paid_to_date(loan)
    return nil unless loan.first_payment_on
    loan.first_payment_on - 1.month
  end

  def signify num
    return [num, '0'] unless num && num < 0
    [-num, '-']
  end

end
