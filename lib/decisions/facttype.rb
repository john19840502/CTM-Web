module Decisions
  class Facttype
    attr_reader :name, :loan
    attr_accessor :fact_types

    def initialize(name, options = {})
      @name = name
      @loan       = options[:loan]
      @event_id   = options[:event_id] || nil
      @debug = options[:debug] || false
      @fact_types = Hash.new(0)
    end

    def flow_name
      Decisions::Flow::FLOWS[name.to_sym][:name]
    end

    def execute
      Array(flow_fact_types).each do |flow_fact_type|
        begin
          fact_types[flow_fact_type] = self.send(flow_fact_type.underscore)
        rescue => e
          raise unless @debug
          fact_types[flow_fact_type] = "Failed to calculate #{flow_fact_type}:  #{e.message}"
        end
      end

      fact_types
    end

    def flow_fact_types
      Ctmdecisionator::Flow.explain(flow_name).fact_types.map(&:model_mapping).uniq
    end

    # THESE METHODS CORRESPOND TO FACT TYPE NAMES
    def registration_tracking_intent_to_proceed_date
      loan.custom_fields.intent_to_proceed_date_string
    end

    def borrower_paid_broker_compensation_amount
      lines = loan.hud_lines.gfe.with_category_and_paid_to('OriginationCharges','Broker')
      brw = lines.select{|hl| hl.paid_by == "Borrower"}.map(&:total_amt).compact.sum
      mult = lines.
        select{|line| line.paid_by == "Multiple"}.
        flat_map(&:paid_by_fees).
        select{|fee| fee.paid_by_type == "Borrower"}.
        map(&:pay_amount).map(&:to_f).
        inject(0, :+)
      brw + mult
    end

    def le_premium_pricing_amount
      premium_pricing = loan.hud_lines.gfe.by_fee_name('Premium Pricing').first
      premium_pricing.nil? ? nil : premium_pricing.total_amt.to_f
    end

    def le_mortgage_insurance_amount 
      total   = loan.hud_lines.hud_line_value('Mortgage Insurance')
      monthly = loan.hud_lines.hud_line_value('Mortgage Insurance', :monthly_amt)

      return 0.0 if monthly == 0.0 && total == 0.0
      return monthly if monthly > 0.0
      return 0.0
    end

    def mortgage_insurance_amount1003
      loan.mortgage_insurance_amount_1003
    end

    def warranty_deed_fee
      get_total_amt_rate_perc_from_hud nil, 'Warranty Deed Prep/Review', 'total_amt'
    end

    def mi_company_name
      case loan.mi_datum.try(:mi_company_id)
      when 1669
        "GE"
      when 1670
        "PMI"
      when 1671
        "RADIAN"
      when 1672
        "RMIC"
      when 1673
        "MGIC"
      when 1674
        "UNITED GUARANTY"
      when 3124
        "GENWORTH FINANCIAL"
      when 8352
        "ESSENT GUARANTY"
      when 20532
        "HUD"
      when 32602
        "TRIAD"
      else
        nil
      end
    end
    
    def ethnicity_for_borrower(borrower_id)
      ethnicity_result = get_right_borrower(borrower_id)

      case ethnicity_result.try(:hmda_ethnicity_type)
      when 'NotApplicable'
        'Not Applicable'
      when 'NotHispanicOrLatino'
        'Not Hispanic Or Latino'
      when 'HispanicOrLatino'
        'Hispanic Or Latino'
      when 'InformationNotProvidedByApplicantInMailInternetOrTelephoneApplication'
        'Information Not Provided'
      else
        ''
      end
    end

    def borrower_ethnicity
      ethnicity_for_borrower(1)
    end

    def borrower2_ethnicity
      ethnicity_for_borrower(2)
    end

    def borrower3_ethnicity
      ethnicity_for_borrower(3)
    end

    def borrower4_ethnicity
      ethnicity_for_borrower(4)
    end

    def not_borrower_checked_race_box(borrower_id)
      !government_monitoring_value(get_right_borrower(borrower_id), 'race_national_origin_refusal_indicator') ? "Yes" : "No"
    end

    def borrower_checked_race_box(borrower_id)
      government_monitoring_value(get_right_borrower(borrower_id), 'race_national_origin_refusal_indicator') ? "Yes" : "No"
    end

    def borrower_not_applicable_race
      not_borrower_checked_race_box(1)
    end

    def borrower2_not_applicable_race
      not_borrower_checked_race_box(2)
    end

    def borrower3_not_applicable_race
      not_borrower_checked_race_box(3)
    end

    def borrower4_not_applicable_race
      not_borrower_checked_race_box(4)
    end

    def borrower_information_not_provided
      borrower_checked_race_box(1)
    end

    def borrower2_information_not_provided
      borrower_checked_race_box(2)
    end

    def borrower3_information_not_provided
      borrower_checked_race_box(3)
    end

    def borrower4_information_not_provided
      borrower_checked_race_box(4)
    end 

    def gender_for_borrower(borrower_id)
      gender_result = government_monitoring_value(get_right_borrower(borrower_id), 'gender_type')

      case gender_result
      when 'Female', 'Male'
        gender_result
      when 'NotApplicable'
        'Not Applicable'
      when 'InformationNotProvidedUnknown'
        'Information Not Provided'
      else
        nil
      end
    end

    def borrower_gender
      gender_for_borrower(1)
    end

    def borrower2_gender
      gender_for_borrower(2)
    end

    def borrower3_gender
      gender_for_borrower(3)
    end

    def borrower4_gender
      gender_for_borrower(4)
    end

    def race_set_for_borrower?(borrower_id)
      borrower = get_right_borrower(borrower_id)
      return false if borrower.nil?

      race = loan.loan_general.hmda_races.where("borrower_id = '#{borrower.borrower_id}' and hmda_race_type is not null")
      race.size > 0
    end

    def borrower_race
      race_set_for_borrower?(1) ? 'Yes' : 'No'
    end

    def borrower2_race
      race_set_for_borrower?(2) ? 'Yes' : 'No'
    end

    def borrower3_race
      race_set_for_borrower?(3) ? 'Yes' : 'No'
    end

    def borrower4_race
      race_set_for_borrower?(4) ? 'Yes' : 'No'
    end

    def application_taken_by
      case loan.interviewer.try(:application_taken_method_type)
      when 'FaceToFace'
        'Face-to-Face'
      when 'Internet'
        'Internet'
      when 'Mail'
        'Mail'
      when 'Telephone'
        'Telephone'
      else
        nil
      end
    end

    def number_of_borrowers
      num_borrowers = loan.borrowers.count
      num_borrowers > 0 ? num_borrowers : nil
    end

    def voe_completed_date
      date = loan.loan_notes_notes.voe_completed_dates.order(created_date: :desc).first.try(:created_date)
      format_date date
    end

    def calculated_upfront_guarantee_financed_line_g_amount
      base_loan_amount = loan.mortgage_term.base_loan_amount.to_f
      round_value (base_loan_amount / 0.9725).floor * 0.0275
    end

    def calculated_upfront_guarantee_financed_line_n_amount
      round_value calculated_upfront_guarantee_financed_line_g_amount.floor
    end

    def escrow_waiver_type
      loan.additional_loan_datum && loan.additional_loan_datum.escrow_waiver_type ? loan.additional_loan_datum.escrow_waiver_type : nil
    end

    def flood_escrow_amount
      loan.hud_lines.gfe.with_category_and_fee_name_start_with('InitialEscrowPaymentAtClosing','Flood Ins',:monthly_amt).round(2)
    end
 
    def total_escrow_amount
      loan.hud_lines.gfe.with_category_and_fee_name_start_with('InitialEscrowPaymentAtClosing', '').round(2)
    end

    def arm_qualifying_rate
      loan.try(:arm).try(:qualifying_rate_percent)
    end

    def aus_risk_assessment
      loan.transmittal_datum && loan.transmittal_datum.au_engine_type  
    end

    def aus_recommendation
      loan.send(:aus_recommendation)
    end

    def base_loan_amount1003
      loan.mortgage_term && loan.mortgage_term.base_loan_amount.to_s  
    end
    
    def channel_name
      FactTranslator.channel_name(loan.channel)  
    end

    def cltv
      loan.cltv  
    end

    def county_loan_limit
      county_limit = loan.send(:county_loan_limit)

      raise 'Unexpected response from County Loan Limit service (length)' if county_limit.present? && county_limit.length > 15
      return county_limit
    end

    def dti
      loan.debt_to_income_ratio
    end

    def fieldwork_obtained
      loan.try(:transmittal_datum).try(:fieldwork_obtained)  
    end

    def first_time_homebuyer
      loan.first_time_homebuyer? ? 'Yes' : 'No'  
    end

    def harp_type_of_mi
      if loan.trid_loan?
        c_field = loan.custom_fields.where(form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionHarpMI").first

        if c_field.nil?
          if loan.channel == "W0-Wholesale Standard"
            c_field = loan.custom_fields.where(form_unique_name: "Wholesale Initial Disclosure Request", attribute_unique_name: "If Harp Loan").first
          else
            c_field = loan.custom_fields.where(form_unique_name: "Retail Initial Disclosure Request", attribute_unique_name: "If Harp Loan").first
          end
        end

        return nil if c_field.nil?
        translate_harp c_field.attribute_value
      else
        harp_attr_val = loan.custom_fields.where(attribute_label_description: "If this is a HARP Loan, what is the type of current MI?").first.try(:attribute_value)
        translate_harp harp_attr_val
      end
    end

    def harp_type_of_mi_value
      "fix me"
    end

    def hcltv
      loan.hcltv  
    end

    def hpml_status
      loan.hpml_status
    end

    def income_doc_expiration_date
      loan.try(:underwriting_conditions) && loan.check_underwriting_condition_expiration_date('Income Expiration')
    end

    def initial_rate_lock_date
      loan.lock_loan_datum && loan.lock_loan_datum.initial_lock_performed_date && format_date(loan.lock_loan_datum.initial_lock_performed_date)
    end

    def initial_rate_sheet_date
      loan.lock_price && format_date(loan.lock_price.locked_at)
    end

    def interest_rate1003
      loan.mortgage_term.try(:requested_interest_rate_percent)
    end

    def is_veteran_exempt
      thing = loan.va_loan.try(:funding_fee_exempt_indicator)
      return nil if thing.nil?
      thing ? 'Yes' : 'No'
    end

    def lender_paid_broker_compensation_amount
      loan.hud_lines.gfe.hud_line_value("Lender Paid Broker Compensation")
    end

    def line902_paid_by_type
      loan.hud_lines.select{|line| line.line_num == 902 && line.hud_type == "GFE"}.first.try(:paid_by)
    end

    def loan_product_name
      FactTranslator.loan_product_name(loan.loan_general.try(:product_code))
    end

    def loan_term_months
      loan.mortgage_term.try(:loan_amortization_term_months)
    end

    def loan_status
      return 'Closing Cancel Postponed' if loan.loan_status == 'Closing Cancelled/Postponed'
      return 'U/W Modified w/Conditions' if loan.loan_status == 'UW Modified w/Conditions'
      return 'U/W Pending Second Review' if loan.loan_status == 'UW Pending 2nd Review'
      loan.loan_status
    end

    def lowest_fico_score
      LowestFicoScore.new(loan.pe_credit_scores).call
    end

    def lp_override_reserves_amount
      loan.transaction_detail.try(:fre_reserves_amount)  
    end

    def ltv
      loan.ltv  
    end

    def mi_program
      x = loan.mi_datum.try(:mi_program_1003).to_s
      case x
        when "1" then "Lender Paid"
        when "2" then "Monthly Premium"
        when "3" then "Risked Based Single Premium"
        when "4" then "Single Premium"
        when "5" then "Split Premium"
        when "6" then "A Minus"
        when "" then nil 
        else raise "unrecognized mi_program_1003 value '#{x}'"
      end
    end

    def mi_coverage_percentage
      expense = loan.proposed_housing_expenses.select{|e| e.housing_expense_type == "MI"}.first
      expense.try(:mi_coverage_percent).try(:to_f)
    end

    def monthly_mip_percentage
      loan.fha_loan.try(:coverage_renewal_rate_percent)
    end

    def number_of_financed_properties
      loan.number_of_financed_properties  
    end

    def number_of_units
      FactTranslator.number_of_units(loan.num_of_units)  
    end

    def occupancy_type
      FactTranslator.occupancy_type(loan.occupancy)  
    end

    def offering_identifier
      identifier = loan.try(:loan_feature).try(:fre_offering_identifier)
      case identifier
      when "241"
        return "Home Possible"
      when "250"
        return "Home Possible Advantage"
      when "251"
        return "Home Possible Advantage for HFAs"
      when "310"
        return "Relief Refinance - Open Access"
      else
        nil
      end
    end

    def property_state
      loan.gfe_property_state
    end

    def property_type
      pt = FactTranslator.property_type_indicator(loan.gse_property_type) if (loan.try(:transmittal_datum).try(:au_engine_type).eql?('LP') && loan.try(:property).try(:planned_unit_development_indicator))
      pt ||= FactTranslator.property_type(loan.gse_property_type) 
      return pt || loan.gse_property_type
    end

    def property_purchase_price
      loan.purchase_price_amount  
    end

    def proposed_monthly_mortgage_insurance_payment
      mi_housing_expense = loan.proposed_housing_expenses.where(housing_expense_type: "MI").first
      mi_housing_expense.try(:payment_amount)
    end

    def pud_indicator
      loan.property.try(:planned_unit_development_indicator) ? 'Yes' : 'No'  
    end

    def purpose_of_loan
      FactTranslator.purpose_of_loan(loan.loan_type)
    end

    def purpose_of_refinance
      FactTranslator.purpose_of_refinance(loan.purpose_of_refinance)
    end

    def rate_lock_request_lender_paid_mi
      indicator = loan.lock_loan_datum.try(:lender_paid_mi)
      return nil if indicator.nil?
      indicator ? 'Yes' : 'No'
    end

    def rate_lock_request_mi_required
      indicator = loan.lock_loan_datum.try(:mi_indicator)
      return nil if indicator.nil?
      indicator ? 'Yes' : 'No'
    end

    def rate_lock_request_originator_compensation
      value = loan.lock_loan_datum.try(:originator_compensation).try(:to_s)
      return 'Lender Paid' if value == '2'
      return 'Borrower Paid' if value == '1'
      nil
    end

    def rate_lock_status
      return "Not Locked" unless loan.lock_loan_datum
      loan.lock_price.try(:is_loan_locked?) ? 'Locked' : 'Expired'
    end

    def renewal_schedule_mortgage_insurance_amount
      premium_rate = loan.loan_general.mi_renewal_premia.first_premium.try!(:rate).to_f
      amt = loan.loan_general.try!(:mortgage_term).try!(:borrower_requested_loan_amount).to_f
      ((premium_rate * amt / 100.0) / 12).round(2)
    end

    def requested_mortgage_insurance_type
      if loan.trid_loan?
        c_field = loan.custom_fields.where(form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionMIType").first

        if c_field.nil?
          if loan.channel == "W0-Wholesale Standard"
            c_field = loan.custom_fields.where(form_unique_name: "Wholesale Initial Disclosure Request", attribute_unique_name: "MI Type").first
          else
            c_field = loan.custom_fields.where(form_unique_name: "Retail Initial Disclosure Request", attribute_unique_name: "MIType").first
          end
        end

        return nil if c_field.nil? || c_field.attribute_value == 'P'
        translate_requested_mortgage c_field.attribute_value

      else
        mi_req_val = loan.custom_fields.where(attribute_label_description: "If MI (Conventional Loans Only)  is required, what type of MI is being requested?").first.try(:attribute_value)
        translate_requested_mortgage mi_req_val
      end

    end

    def risk_assessment
      loan.aus_type  
    end

    def signature_date1003
      b = loan.borrowers.select{|b| b.borrower_id == 'BRW1'}.last
      format_date(b.application_signed_date) unless b.nil?
    end

    def submit_to_underwriting_date
      loan.underwriter_submission_received_at && format_date(loan.underwriter_submission_received_at)
    end

    def subordinate_financing
      loan.subordinate_financing?  
    end

    def title_doc_expiration_date
      loan.try(:underwriting_conditions) && loan.check_underwriting_condition_expiration_date('Title Expiration')
    end

    def total_funds_required
      loan.total_funds_required
    end

    def total_gift_amount
      loan.total_gift_amount    
    end

    def total_loan_amount_first_mortgage
      loan.total_loan_amount_first_mortgage     
    end

    def total_verified_assets
      loan.total_verified_assets.round(2)  
    end

    def total_verified_borrower_funds
      loan.total_verified_borrower_funds.round(2)
    end

    def underwriting_status
      loan.underwriting_status  
    end

    def upfront_mip_percentage
      loan.fha_loan.try(:upfront_mi_premium_percent)
    end

    def va_funding_fee_amount
      if loan.trid_loan?
        get_total_amt_rate_perc_from_hud nil, 'Federal VA Funding Fee', 'total_amt'
      else
        return nil unless loan.mortgage_term.mortgage_type == "VA"
        loan.transaction_detail.try(:mi_and_funding_fee_total_amount).try(:to_f)
      end
    end

    def funding_date
      loan.loan_feature.requested_settlement_date && format_date(loan.loan_feature.requested_settlement_date)
    end

    def funding_date_calendar_code
      funding_date = loan.loan_feature && loan.loan_feature.requested_settlement_date
      return nil if funding_date.nil?
      return 'Federal Holiday' if funding_date.to_date.holiday?(:us)
      return 'Weekend' if (funding_date.to_date.saturday? || funding_date.to_date.sunday?)
      return 'Good Date'
    end

    def rate_lock_expiration_date
      loan.lock_expiration_at && format_date(loan.lock_expiration_at)
    end

    def closing_date
      c_date = loan.loan_feature.try(:loan_scheduled_closing_date) || loan.loan_feature.try(:requested_closing_date)
      format_date c_date
    end

    def closing_date_calendar_code 
      closing_date = loan.loan_feature &&  loan.loan_feature.requested_closing_date
      return nil if closing_date.nil?
      return 'Federal Holiday' if closing_date.to_date.holiday?(:us)
      return 'Weekend' if (closing_date.to_date.saturday? || closing_date.to_date.sunday?)
      return 'Good Date'
    end

    def closing_plus_rescission_date
      loan.loan_feature.requested_closing_date && loan.calculate_closing_plus_rescission_date
    end

    def assets_doc_expiration_date
      loan.try(:underwriting_conditions) && ( loan.check_underwriting_condition_expiration_date('Asset Expiration') || loan.check_underwriting_condition_expiration_date('Assets Expiration'))
    end

    def credit_doc_expiration_date
      loan.try(:underwriting_datum) && loan.try(:underwriting_datum).try(:credit_docs_expire_at) && format_date(loan.try(:underwriting_datum).try(:credit_docs_expire_at))
    end

    def appraisal_doc_expiration_date
      loan.try(:underwriting_datum) && loan.try(:underwriting_datum).try(:appraisal_expire_at) && format_date(loan.try(:underwriting_datum).try(:appraisal_expire_at))
    end

    def credit_report_expiration_date
      loan.try(:underwriting_conditions) && loan.check_underwriting_condition_expiration_date('Credit Report Expiration')
    end

    def mshda_affidavit_post_closing_note_indicator
      loan.try(:loan_notes_notes) && loan.mshda_note_indicator_check
    end

    def two_business_days_from_today
      two_days = 2.business_days.since(Date.today)
      calculate_business_days_minus_fed_holiday(two_days)
    end

    def five_business_days_from_today
      five_days = 5.business_days.since(Date.today)
      calculate_business_days_minus_fed_holiday(five_days)
    end

    def calculate_business_days_minus_fed_holiday(dt)
      if dt.to_date.holiday?(:us)
        date = 1.business_day.after(dt)
      else
        date = dt
      end
      format_date date.to_date
    end
    
    def tand_i_closing
      loan.try(:hud_lines) && loan.calculate_tandl_closing
    end

    def tand_i_underwriting
      loan.try(:proposed_housing_expenses) && loan.calculate_tandl_underwriting
    end

    def rate_lock_request_escrow_waiver
      loan.try(:lock_loan_datum) && loan.rate_lock_request_escrow_waiver
    end

    def escrow_waiver_indicator1003
      loan.loan_general && loan.loan_general.escrow_from_1003
    end

    def upfront_guarantee_fee_percentage
      funding_fee_total_amt = loan.transaction_detail.mi_and_funding_fee_total_amount.to_f rescue 0
      borrower_req_loan_amt = loan.mortgage_term.borrower_requested_loan_amount.to_f rescue 0
      return 0 if (borrower_req_loan_amt == 0)
      guarantee_fee = (funding_fee_total_amt / borrower_req_loan_amt * 100).round(2)
    end  

    def project_classification
      return nil if loan.try(:loan_feature).nil?
      fnm_project_desc = loan.loan_feature.fnm_project_classification_type 
      fnm_project_desc = loan.loan_feature.fnm_project_classification_type_other_description if fnm_project_desc == 'Other'
      fnm_project_desc = loan.loan_feature.gse_project_classification_type if fnm_project_desc.blank?
      return (fnm_project_desc.blank? ? nil : FactTranslator.project_classification(fnm_project_desc))
    end

    def mortgage_insurance_ltv
      loan.mi_ltv
    end

    def fha_endorsement_date
      get_attribute_value_for_label_description("FHA Endorsement Date")
    end

    def cpm_project_id_number
      get_attribute_value_for_label_description("CPM Project ID Number")
    end

    def pers_list_indicator
      get_attribute_value_for_label_description("Is the project on the PERS list?")
    end

    def pers_list_expiration_date
      get_attribute_value_for_label_description("PERS Expiration Date")
    end

    def get_attribute_value_for_label_description label_desc
      loan.custom_fields.select {|a| a.attribute_label_description.include?("#{label_desc}")}.first.attribute_value rescue nil
    end

    def borrower_total_income
      loan.loan_general.calculations.select {|cal| cal.name == "TotalMonthlyIncome"}.first.value.to_f rescue nil
    end

    def sum_of_liquid_assets
      loan.try(:assets) && loan.calculate_sum_of_liquid_assets
    end

    def amortization_type_gfe
      result = loan.loan_general.try(:mortgage_term) && loan.loan_general.mortgage_term.loan_amortization_type

      case result
        when "AdjustableRate"
          return "ARM"
        when "Fixed"
          return "Fixed"
        when "Other"
          return loan.loan_general.mortgage_term.other_amortization_type_description
        else
          return nil
      end
    end

    def disclosure_type
      loan.loan_general.loan_events && loan.loan_general.loan_events.where{event_description.in ["DocMagic Initial Disclosure Request", "DocMagic Redisclosure Package Request"]}.first.event_description rescue nil
    end

    def arm_initial_adjustment_period_gfe
      loan.loan_general.try(:gfe_detail) && loan.loan_general.gfe_detail.gfe_change_month
    end

    def gfe_maximum_interest_rate
      result = loan.loan_general.try(:gfe_detail) && loan.loan_general.gfe_detail.gfe_maximum_interest_rate
      result.nil? ? nil : result.to_f
    end

    def can_monthly_amount_rise_indicator
      result = loan.loan_general.try(:gfe_detail) && loan.loan_general.gfe_detail.gfe_can_monthly_amount_rise_indicator
      return "Yes" if result == true
      return "No" if result == false
      nil
    end

    def tbd_property_address_indicator
      result = (loan.loan_general.property && ((loan.loan_general.property.address.downcase.include?('tbd') unless loan.loan_general.property.address.nil?) || (loan.loan_general.property.street_number.downcase.include?('tbd') unless loan.loan_general.property.street_number.nil?))) || 
      (loan.loan_general.lock_loan_datum && ((loan.loan_general.lock_loan_datum.property_street_address.downcase.include?('tbd') unless loan.loan_general.lock_loan_datum.property_street_address.nil?) || (loan.loan_general.lock_loan_datum.property_street_address_number.downcase.include?('tbd') unless loan.loan_general.lock_loan_datum.property_street_address_number.nil?) || (loan.loan_general.lock_loan_datum.property_street_address_name.downcase.include?('tbd') unless loan.loan_general.lock_loan_datum.property_street_address_name.nil?))) || 
      (loan.loan_general.gfe_loan_datum && ((loan.loan_general.gfe_loan_datum.property_street_address.downcase.include?('tbd') unless loan.loan_general.gfe_loan_datum.property_street_address.nil?) || (loan.loan_general.gfe_loan_datum.property_street_address_number.downcase.include?('tbd') unless loan.loan_general.gfe_loan_datum.property_street_address_number.nil?) || (loan.loan_general.gfe_loan_datum.property_street_address_name.downcase.include?('tbd') unless loan.loan_general.gfe_loan_datum.property_street_address_name.nil?)))
      return 'Yes' if result == true
      return 'No' 
    end
  
    def periodic_cap_lock
      loan.loan_general.lock_loan_datum.interval_cap.to_f rescue nil
    end

    def lifetime_cap_lock
      loan.loan_general.lock_loan_datum.lifetime_cap.to_f rescue nil
    end

    def first_rate_adjustment_cap_lock
      loan.loan_general.lock_loan_datum.initial_cap.to_f rescue nil
    end

    def arm_index_value_lock
      loan.loan_general.arm.index_current_value_percent.to_f rescue nil
    end

    def arm_index_value1003
      loan.loan_general.arm.index_current_value_percent.to_f rescue nil
    end

    def periodic_cap1003
      loan.loan_general.rate_adjustment.subsequent_cap_percent.to_f rescue nil
    end

    def first_rate_adjustment_cap1003
      loan.loan_general.rate_adjustment.first_change_cap_rate.to_f rescue nil
    end

    def lifetime_cap1003
      loan.loan_general.rate_adjustment.lifetime_cap_percent && loan.loan_general.rate_adjustment.lifetime_cap_percent.to_f rescue nil
    end

    def arm_index_margin1003
      loan.loan_general.arm.index_margin_percent.to_f rescue nil
    end

    def arm_index_code
      index_type = loan.loan_general.arm.index_type rescue nil
      return nil if index_type.nil?
      FactTranslator.arm_index_code(index_type)
    end

    def arm_subsequent_adjustment_period1003
      loan.loan_general.rate_adjustment.subsequent_rate_adjustment_months rescue nil
    end

    def arm_initial_adjustment_period1003
      loan.loan_general.rate_adjustment.first_rate_adjustment_months rescue nil
    end

    def fha_total_gift_amount
      if(loan.mortgage_term.try(:mortgage_type).in?(%w(FHA VA FarmersHomeAdministration)) && loan.down_payments.map{|dp| dp.downpayment_type == "FHAGiftSourceRelative"}.any?)
        return loan.down_payments.select{|dp| dp.downpayment_type == "FHAGiftSourceRelative"}.map{|gift| gift.amount.to_f}.sum
      else
        return 0
      end
    end

    def flood_insurance_indicator
      indicator = loan.try(:flood_determination).try(:special_flood_hazard_area_indicator)
      return nil if indicator.nil?
      indicator ? 'Yes' : 'No'
    end

    def flood_insurance_expiration_date
      exp_date = loan.custom_fields.where(form_unique_name: 'Expirations Dates', attribute_unique_name: 'FloodExpDate').first rescue nil
      exp_date.try(:attribute_value)
    end

    def flood_insurance_effective_date
      effective_date = loan.custom_fields.where(form_unique_name: 'Expirations Dates', attribute_unique_name: 'FloodEffectiveDate').first rescue nil
      effective_date.try(:attribute_value)
    end

    def flood_escrow_months
      lines = loan.hud_lines.select do |line| 
        line.hud_type == "GFE" &&
          line.sys_fee_name.start_with?("Flood Ins") &&
          line.fee_category == "InitialEscrowPaymentAtClosing" 
      end
      lines.map(&:num_months).compact.inject(0, &:+)
    end

    def homeowners_insurance_effective_date
      date = get_custom_field_value("Expirations Dates", "HOInsEffectiveDate" )
      format_date date
    end

    def homeowners_insurance_expiration_date
      date = get_custom_field_value("Expirations Dates", "HOInsExpDate")
      format_date date
    end

    def homeowners_insurance_condo_master_policy_expiration_date
      date = get_custom_field_value("Expirations Dates", "CondoMPExpDate")
      format_date date
    end

    def homeowners_insurance_condo_master_policy_effective_date
      date = get_custom_field_value("Expirations Dates", "CondoMPEffectiveDate")
      format_date date
    end

    def closing_verifications_expiration_date
      date = get_custom_field_value("Expirations Dates", "ClosingVerExpDate")
      format_date date
    end

    def project_classification_field1003
      FactTranslator.project_classification(loan.try(:loan_feature).try(:gse_project_classification_type))
    end

    def project_classification_field1008
      return nil if loan.try(:loan_feature).nil?
      fnm_project_desc = loan.loan_feature.fnm_project_classification_type 
      fnm_project_desc = loan.loan_feature.fnm_project_classification_type_other_description if fnm_project_desc == 'Other'
      prj_classification = FactTranslator.project_classification(fnm_project_desc)
      return nil if prj_classification.nil? || prj_classification.include?('FHA')
      prj_classification
    end

    def trid_application_received_date
      app_received = loan.try(:trid_application_date)
      format_date app_received
    end

    def redisclosure_date
      event_date = loan.loan_general.loan_events.where(event_description: 'DocMagic Redisclosure Package Request').last.try(:event_date)
      format_date event_date
    end

    def redisclosure_date_plus_six
      event_date = redisclosure_date
      return nil if event_date.nil?
      plus_six_days(event_date)
    end

    def appraisal_one_sent_date
      appraisal_one = loan.try(:underwriting_datum).try(:appraisal_sent_to_borrower)
      format_date appraisal_one
    end

    def appraisal_one_sent_date_plus_three
      appraisal_date = appraisal_one_sent_date
      return nil if appraisal_date.nil?
      plus_three_days(appraisal_date)
    end

    def appraisal_one_delivery_method
      del_method = loan.try(:underwriting_datum).try(:appraisal_delivery_method)
      return_delivery_method del_method
    end

    def appraisal_two_sent_date
      appraisal_two = loan.try(:underwriting_datum).try(:second_appraisal_sent_to_borrower)
      format_date appraisal_two
    end

    def lock_borrower_credit_score
      loan.try(:lock_loan_datum).try(:borrower_credit_score)
    end

    def lock_co_borrower_credit_score
      loan.try(:lock_loan_datum).try(:co_borrower_credit_score)
    end

    def uw_conditions_borrower_credit_score
      loan.try(:underwriting_datum).try(:borrower_credit_score)
    end

    def uw_conditions_co_borrower_credit_score
      loan.try(:underwriting_datum).try(:co_borrower_credit_score)
    end

    def downloaded_borrower_credit_score
      primary_borrower = loan.borrowers.where(borrower_id: 'BRW1').last
      primary_borrower.try(:middle_credit_score)
    end

    def downloaded_co_borrower_credit_score
      co_borrowers = loan.borrowers.where{ borrower_id != 'BRW1'}
      co_borrowers.map(&:middle_credit_score).compact.min
    end

    def appraisal_two_sent_date_plus_three
      appraisal_date = appraisal_two_sent_date
      return nil if appraisal_date.nil?
      plus_three_days(appraisal_date)
    end

    def appraisal_two_sent_date_plus_six
      appraisal_date = appraisal_two_sent_date
      return nil if appraisal_date.nil?
      plus_six_days(appraisal_date)
    end

    def total_discount_fee_amount
      get_total_amt_rate_perc_from_hud 802, 'Discount Points', 'total_amt'
    end

    def total_origination_fee_amount
      get_total_amt_rate_perc_from_hud nil, 'Broker Compensation', 'total_amt'
    end

    def originator_compensation_percentage
      get_total_amt_rate_perc_from_hud 826, 'Originator Compensation - Lender Paid', 'rate_perc'
    end

    def total_originator_compensation_amount
      get_total_amt_rate_perc_from_hud nil, 'Lender Paid Broker Compensation', 'total_amt'
    end

    def total_premium_pricing_amount
      if loan.trid_loan?
        get_total_amt_rate_perc_from_hud 808, 'Premium Pricing', 'total_amt'
      else
        get_total_amt_rate_perc_from_hud 827, 'Lender Credit', 'total_amt'
      end
    end

    def total_escrow_months
      lines = @loan.hud_lines.select{|line| line.hud_type == 'GFE' && line.fee_category == 'InitialEscrowPaymentAtClosing'}
      return 0 if lines.empty?
      lines.map(&:num_months).compact.inject 0, &:+
    end

    def lender_credit_percentage
      get_total_amt_rate_perc_from_hud 827, 'Lender Credit', 'rate_perc'
    end

    def total_lender_credit_amount
      get_total_amt_rate_perc_from_hud 827, 'Lender Credit', 'total_amt'
    end

    def originator_compensation_type
      if loan.channel == "W0-Wholesale Standard"
        c_field = loan.custom_fields.where(form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionCompType").first

        if c_field.nil? || c_field.attribute_value == 'Please Select'
          c_field = loan.custom_fields.where(form_unique_name: "Wholesale Initial Disclosure Request", attribute_unique_name: "Comp Type").first
        end

        return nil if c_field.nil?
        case c_field.attribute_value
        when /Borrower/i
          return "Borrower Paid"
        when /Lender/i
          return "Lender Paid"
        else
          return nil
        end 
      else
        return "Lender Paid"
      end
    end

    def appraisal_one_sent_date_plus_six
      appraisal_one_date = appraisal_one_sent_date
      return nil if appraisal_one_date.nil?
      plus_six_days(appraisal_one_date)
    end

    def appraisal_consent_to_waive_date
      loan.try(:underwriting_datum).try(:consent_to_waive_delivery_received) && format_date(loan.underwriting_datum.consent_to_waive_delivery_received)
    end

    def appraisal_two_delivery_method
      del_method = loan.try(:underwriting_datum).try(:second_appraisal_delivery_method)
      return_delivery_method del_method
    end

    def notice_of_special_flood_hazards_delivery_date
      del_date = loan.try(:service_orders).where('sent_method IS NOT NULL').first.try(:sent_date)
      format_date del_date
    end

    def appraisal_type
      if !loan.try(:transmittal_datum).try(:property_appraised_value_amount).nil? && loan.try(:transmittal_datum).try(:property_estimated_value_amount).nil?
        return "Actual"
      elsif !loan.try(:transmittal_datum).try(:property_estimated_value_amount).nil?
        return "Estimated"
      end
    end

    def appraisal_year_built
      loan.property.try(:structure_built_year)
    end

    def appraiser_license_state
      loan.transmittal_datum.try(:appraiser_license_state)
    end

    def appraiser_license_number
      loan.transmittal_datum.try(:appraiser_license_number)
    end

    def appraisal_company_name
      loan.transmittal_datum.try(:appraiser_company)
    end

    def property_appraised_value
      loan.transmittal_datum.try(:property_appraised_value_amount).try(:to_f) || loan.transmittal_datum.try(:property_estimated_value_amount).try(:to_f)
    end

    def appraiser_name
      loan.transmittal_datum.try(:appraiser_name)
    end

    def property_county_name
      loan.property.try(:county)
    end


    def closing_cost_expiration_date
      get_date('lock_price', 'lock_expired_at')
    end

    def le_redisclosure_sent_date
      get_date('gfe_detail', 'gfe_redisclosure_date')
    end

    def pest_inspection_fee_amount
      get_total_amt_rate_perc_from_hud nil, 'Pest Inspection Fee', 'total_amt'
    end

    def title_vendor_fee_amount
      lines = loan.hud_lines.select do |line| 
        line.hud_type == "GFE" && line.sys_fee_name.start_with?("Title") &&
          line.fee_category == "ServicesYouCanShopFor" 
      end
      return nil unless lines.any?
      lines.map(&:total_amt).compact.inject(0, &:+).to_f
    end

    def survey_fee_amount
      get_total_amt_rate_perc_from_hud nil, 'Survey Fee', 'total_amt'
    end

    def initial_cd_sent_to_borrower_date
      get_date('loan_detail', 'cd_disclosure_date')
    end

    def no_lender_admin_fee_llpa_indicator
      return "No" unless loan.channel == Channel.wholesale.identifier &&
        loan.price_adjustments.any? {|pa| pa.label == "018 No Lender Admin Fee" && pa.amount.to_f != 0}
      "Yes"
    end

    def broker_nmls_number
      loan.interviewer.try(:institution_nmls_id)
    end

    def loan_officer_nmls_number
      loan.interviewer.try(:individual_nmls_id)
    end

    def loan_officer_name
      loan.try(:interviewer).try(:name)
    end

    def initial_le_sent_date
      get_date('gfe_detail', 'initial_gfe_disclosure_date')
    end

    def total_box_g_months
      lines = loan.hud_lines.select {|line| line.fee_category == "InitialEscrowPaymentAtClosing" && line.hud_type == "GFE" }
      return nil unless lines.any?
      lines.map(&:num_months).compact.inject 0, &:+
    end

    #IsThisATBD is being translated as 'is_this_atbd' instead of 'is_this_a_tbd'
    def is_this_atbd
      fields = loan.custom_fields.where(form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionPreapproval")
      return nil if fields.empty?
      attribute = fields.first.attribute_value
      case attribute
      when "Y" 
        return "Yes"
      when "N" 
        return "No"
      when "Required Field, Please Select..." 
        return ""
      else
        return nil
      end
    end

    def total_box_g_amount
      lines = loan.hud_lines.select {|line| line.fee_category == "InitialEscrowPaymentAtClosing" && line.hud_type == "GFE" }
      return nil unless lines.any?
      lines.map(&:total_amt).compact.inject 0, &:+
    end

    def intent_to_proceed_date
      date = loan.loan_general.try(:intent_to_proceed_date).presence
      format_date date
    end

    def mansion_tax_amount
      get_total_amt_rate_perc_from_hud nil, 'Mansion Tax', 'total_amt'
    end

    def transfer_tax_amount
      lines = loan.hud_lines.select do |line|
        line.hud_type == "GFE" &&
          line.fee_category == "TaxesAndOtherGovernmentFees" &&
          line.sys_fee_name =~ /tax/i
      end
      return nil unless lines.any?
      lines.map(&:total_amt).compact.inject 0, &:+
    end
    
    def administration_fee
      get_total_amt_rate_perc_from_hud nil, 'Administration Fee', 'total_amt'
    end

    def recording_fee_amount
      lines = loan.hud_lines.select do |line|
        line.hud_type == "GFE" &&
          (line.sys_fee_name =~ /recording/i ||
           line.sys_fee_name == "GRMA")
      end
      return nil unless lines.any?
      lines.map(&:total_amt).compact.inject 0, &:+
    end

    def le_credit_report_fee_amount
      v = get_total_amt_rate_perc_from_hud(nil, 'Credit Report', 'total_amt')
      v.nil? ? nil : "%.02f" % v
    end

    def state_housing_document_prep_fee
      lines = loan.hud_lines.select{|line| !line.sys_fee_name.nil? && line.sys_fee_name.ends_with?("Doc Prep Fee") && line.fee_category == "OriginationCharges" && line.hud_type == "GFE"}
      lines.first.try(:total_amt).try(:to_f)
    end

    def le_condo_questionnaire_fee_amount
      get_total_amt_rate_perc_from_hud nil, "Condominium Questionnaire", "total_amt"
    end

    def le_appraisal_fee_amount
      get_total_amt_rate_perc_from_hud nil, 'Appraisal Fee', 'total_amt'
    end

    def employee_loan_indicator
      loan.loan_general.try(:additional_loan_datum).try(:employee_loan_indicator) ? "Employee" : "Not Employee"
    end

    def lock_discount_percentage
      amount = lock_net_price
      return nil unless amount.present? && (amount - 100 < 0)
      (amount-100).round(3).abs
    end

    def attorney_doc_prep_fee
      lines = loan.hud_lines.select{|line| line.hud_type == "GFE" && line.sys_fee_name == "Attorney Doc Prep Fee"}
      lines.first.try(:total_amt).try(:to_f)
    end

    def le_flood_cert_fee_amount
      get_total_amt_rate_perc_from_hud nil, 'Flood Determination Fee', 'total_amt'
    end

    def lock_net_price
      loan.try(:lock_price).try(:net_price).try(:to_f)
    end

    def days_since_application_received
      date_today = Time.zone.today
      app_date = loan.try(:application_date).try(:to_date)
      return nil if app_date.nil?
      app_date.business_days_until(date_today)
    end

    def va_homebuyer_usage_indicator
      loan.manual_fact_types.find {|ft| ft.name == "VA Homebuyer Usage Indicator"}.try(:value)
    end

    def type_of_veteran
      loan.manual_fact_types.find {|ft| ft.name == "Type of Veteran"}.try(:value)
    end

    def webva_funding_fee_percentage
      call_flow_as_fact_type 'va_funding_fee_amt'
    end

    def closing_request_submitted_plus10_business_date
      req_date = loan.loan_general.loan_events.closing_request_submitted_events.order('event_date').last.try(:event_date)
      return nil if req_date.nil?
      BusinessTime::Config.work_week = [:mon, :tue, :wed, :thu, :fri, :sat]
      # Name suggests to add 10 business days but requiremtnt is to return 8 business days after closing date
      # AND if the closing date is Saturday return 9 business days after closing date.
      req_date =  req_date.to_date
      if req_date.saturday?
        plus_ten_date = 9.business_days.after(req_date)
      else
        plus_ten_date = 8.business_days.after(req_date)
      end

      if plus_ten_date.to_date.holiday?(:us) 
        plus_ten_date = 0.business_day.after(plus_ten_date)
      end
      BusinessTime::Config.work_week = [:mon, :tue, :wed, :thu, :fri] 
      return format_date plus_ten_date
    end

    def initial_le_sent_plus10_date
      le_date = initial_le_sent_date
      return nil if le_date.nil?
      plus_ten_days(le_date, false)
    end

    def call_flow_as_fact_type flow_key
      begin
        fact_types = Decisions::Facttype.new(flow_key, {loan: loan}).execute
        result = Decisions::Flow.new(flow_key, fact_types).execute
        result[:conclusion]
      rescue => e
        Rails.logger.debug ExceptionFormatter.new(e)
        nil
      end
    end

    def maximum_closing_date
      return call_flow_as_fact_type 'maximum_closing_date' if @event_id.nil?
      get_flow_result 'maximum_closing_date'
    end

    def minimum_closing_date
      return call_flow_as_fact_type 'minimum_closing_date' if @event_id.nil?
      get_flow_result 'minimum_closing_date'
    end

    def mb_closing_date_waiting_period
      return call_flow_as_fact_type 'mb_closing_date_waiting_period' if @event_id.nil?
      get_flow_result 'mb_closing_date_waiting_period'
    end

    def closing_fee_tolerance_date
      return call_flow_as_fact_type 'closing_fee_tolerance' if @event_id.nil?
      get_flow_result 'closing_fee_tolerance'
    end

    def state_housing_underwriting_fee
      has_state_housing_product ? get_total_amt_rate_perc_from_hud(nil, 'Underwriting Fee', 'total_amt') : nil
    end

    def state_housing_origination_fee
      has_state_housing_product ? get_total_amt_rate_perc_from_hud(nil, 'Origination Fee', 'total_amt') : nil
    end

    def state_housing_funding_fee
      return nil unless has_state_housing_product
      lines = loan.hud_lines.select do |line|
        line.sys_fee_name.end_with?("Funding Fee") && line.hud_type == 'GFE'
      end
      round_value lines.first.try(:total_amt)
    end

    def total_poc
      if has_state_housing_product
        credits = @loan.purchase_credits
        credit1 = credits.select{|c| c.source_type == 'BorrowerPaidOutsideClosing'}.first
        credit2 = credits.select{|c| c.credit_type == 'EarnestMoney'}.first
        return credit1.amount + credit2.amount unless credit1.nil? || credit2.nil?
      end
      0
    end

    def downpayment_percentage
      if loan.loan_type == 'Refinance'
        ltv.nil? ? nil : (100 - ltv).round(2)
      else
        base_amt = loan.mortgage_term.try(:base_loan_amount)
        return 0 if property_purchase_price.to_f == 0 || base_amt.nil?
        (100 - ((base_amt.to_f / property_purchase_price.to_f) * 100)).round(2)
      end
    end

    def cd_delivery_method
      method_type = loan.loan_general.try(:loan_detail).try(:cd_disclosure_method_type)
      case method_type
      when 'ElectronicDisclosure'
        'Email'
      when 'FaceToFace'
        'In Person'
      when 'Mail'
        'US Mail'
      when 'Other'
        'Other'
      else
        nil
      end 
    end

    def initial_cd_delivery_plus_six_date
      cd_date = loan.loan_general.try(:loan_detail).try(:cd_disclosure_date)
      cd_date.nil? ? nil : plus_six_days(cd_date)
    end

    def redisclosure_cd_delivery_date
      loan.cd_redisclosure_date || loan.cd_disclosure_date
    end

    def closing_cannot_occur_until_date
      get_date(:gfe_detail, :earliest_closing_date_after_gfe_redisclosure) ||
        get_date(:gfe_detail, :earliest_closing_date_after_initial_gfe_disclosure)
    end

    def cd_proof_of_receipt_date
      reciept_date = loan.loan_general.try(:loan_detail).try(:cd_borrower_received_disclosure)
      format_date reciept_date
    end

    def box_a_discount_percentage
      total_amount = loan.hud_lines.gfe.by_fee_name('Discount Points').try(:first).try(:total_amt).to_f

      if total_amount > 0.0
        original_loan_amount = loan.loan_general.gfe_loan_datum.original_loan_amount
        return ((total_amount / original_loan_amount) * 100).round(3)
      else
        return nil
      end
    end

    def is_this_acema
      attribute_val = {
        "Y" => "Yes",
        "N" => "No",
        "NA" => "N/A",
      }

      if loan.try(:account_info).try(:channel) == "W0-Wholesale Standard"
        wholesale_disclosure_fields = loan.custom_fields.select{|cf| cf.form_unique_name == "Wholesale Initial Disclosure Request" && cf.attribute_unique_name == "NY CEMA"}
        return attribute_val[wholesale_disclosure_fields.first.attribute_value] unless wholesale_disclosure_fields.empty?
      else
        disclosure_fields = loan.custom_fields.select{|cf| cf.form_unique_name == "Retail Initial Disclosure Request" && cf.attribute_unique_name == "NYCEMA"}
        return attribute_val[disclosure_fields.first.attribute_value] unless disclosure_fields.empty?
      end    
    end


    def closer_cd_flag
      loan.cd_flag
    end

    def existing_survey_indicator
      v = loan.manual_fact_types.find {|ft| ft.name == "Existing Survey Indicator"}.try(:value) 
      v || "No"
    end

    def right_to_delay_indicator
      indicator = loan.collect_facttype('right_to_delay')
      indicator.nil? ? 'No' : 'Yes'
    end

    def texas50_a6_indicator
      yesno = loan.collect_facttype('texas_only').try(:value) ||
              loan.is_texas_50A6
      case yesno
      when 'Yes'
        '50A6'
      when 'No'
        'Not 50A6'
      else
        'NA'
      end
    end

    def usda_conditional_commitment_date
      format_date loan.loan_feature.try(:c_commitment_date)
    end

    def e_consent_indicator
      loan.manual_fact_types.find { |ft| ft.name == "E Consent Indicator"}.try :value
    end

    def monthly_guarantee_fee_percentage
      insurance = proposed_monthly_mortgage_insurance_payment
      return nil if insurance.nil?
      base_amt = loan.mortgage_term.try(:base_loan_amount)
      return nil unless base_amt.present?
      # (yearly insurance / base loan amount) * 100
      ((insurance * 12 / base_amt) * 100.0).round(2)
    end

    def mi_certification_number
      loan.mi_datum.try(:mi_certificate_identifier)
    end

    def va_funding_fee_percentage
      return get_total_amt_rate_perc_from_hud nil, "VA funding fee", 'rate_perc' unless loan.trid_loan?

      fee = get_total_amt_rate_perc_from_hud nil, "Federal VA Funding Fee", 'total_amt'
      return nil unless fee
      loan_amt = loan.mortgage_term.try(:base_loan_amount)
      return nil unless loan_amt
      (100.0 * fee / loan_amt).round(2)
    end

    def lock_net_price_amount
      @net_price = loan.try(:lock_price).try(:net_price)
      return 0 if @net_price.nil? || @net_price == 100

      net_pr = @net_price - 100 
      return (net_pr * loan.try(:lock_loan_datum).try(:total_loan_amt).to_f * 0.01).round(2) if net_pr > 0
      net_pr.round(3).abs
    end

    def line_n_amount
      round_value loan.try!(:transaction_detail).try!(:mi_and_funding_fee_financed_amount).try(:to_f)
    end

    def line_g_amount
      round_value loan.try!(:transaction_detail).try!(:mi_and_funding_fee_total_amount).try(:to_f)
    end

    def financed_fee_indicator
      loan.try!(:transaction_detail).try!(:mi_and_funding_fee_financed_amount).to_f > 0.0 ? 'Financed' : 'Not Financed'
    end

    def do_not_wish_to_furnish_borrower1
      borrower = get_right_borrower(1)
      national_origin_refusal_indicator(government_monitoring_value(borrower, 'race_national_origin_refusal_indicator'))
    end

    def do_not_wish_to_furnish_borrower2
      borrower = get_right_borrower(2)
      national_origin_refusal_indicator(government_monitoring_value(borrower, 'race_national_origin_refusal_indicator'))
    end

    def do_not_wish_to_furnish_borrower3
      borrower = get_right_borrower(3)
      national_origin_refusal_indicator(government_monitoring_value(borrower, 'race_national_origin_refusal_indicator'))
    end

    def do_not_wish_to_furnish_borrower4
      borrower = get_right_borrower(4)
      national_origin_refusal_indicator(government_monitoring_value(borrower, 'race_national_origin_refusal_indicator'))
    end

    def total_cash_back
      get_total_amt_rate_perc_from_hud(nil, "Due from Borrower at Closing", 'total_amt', 'HUD')
    end

    def fully_indexed_rate
      roundval = loan.arm.try!(:index_current_value_percent).to_f + loan.arm.try!(:index_margin_percent).to_f
      (roundval * 8).round/8.0
    end

    def cash_from_to_borrower
      return 0 unless loan.loan_type.in?(['Purchase', 'Refinance'])
      td = loan.try!(:transaction_detail)
      mt = loan.try!(:mortgage_term)
      pc = loan.try!(:purchase_credits)
      ls = loan.try!(:liabilities).first

      discount_point = return_0_for_nil get_total_amt_rate_perc_from_hud nil, "Discount Points", "total_amt", "HUD"

      credits = pc.pluck(:amount).map(&:to_f).sum

      cash = (loan.loan_type == "Purchase") ? (td.try!(:purchase_price_amount).to_f - td.try!(:seller_paid_closing_costs_amount).to_f) : ls.try!(:unpaid_balance_amount).to_f

      cash =  cash - mt.try!(:base_loan_amount).to_f + td.try!(:prepaid_items_estimated_amount).to_f + 
              td.try!(:estimated_closing_costs_amount).to_f - credits + td.try!(:subordinate_lien_amount).to_f + discount_point.to_f

      round_value(cash)
    end

    def homebuyer_education_fee
      return_0_for_nil get_total_amt_rate_perc_from_hud nil, 'Homebuyer Education Fee', 'total_amt'
    end

    def lender_paid_compensation_tier_amount
      amount = loan.price_adjustments.
        select {|pa| pa.label =~ /Originator Compensation is Lender Paid and InstId is .* then price adjustment = .*/
        }.last.try!(:amount).to_f
      round_value(amount.abs * loan.lock_loan_datum.try!(:total_loan_amt).to_f * 0.01)
    end

    def institutional_broker_compensation_tier_amount
      tier = loan.comp_tier.try!(:comp_tier).to_f
      requested_loan_amount = loan.mortgage_term.try!(:borrower_requested_loan_amount).to_f
      round_value tier * requested_loan_amount
    end

    private

    def return_0_for_nil val
      val.nil? ? 0 : val
    end

    def get_right_borrower index
      borrowers = loan.loan_general.government_monitorings.order(:borrower_id)
      borrowers[index-1]
    end

    def government_monitoring_value borrower, key
      borrower.try!(key.to_sym)
    end

    def national_origin_refusal_indicator indicator
      indicator ? 'Not Furnished' : 'Furnished'
    end

    def round_value amount, decimal = 2
      amount.nil? ? nil : amount.round(decimal)
    end

    def get_loan_events_event_date event_desc
      format_date loan.loan_general.try(:loan_events).where(event_description: event_desc).first.try(:event_date)
    end

    def yesno value
      return nil if value.nil?
      value ? "Yes" : "No"
    end

    def has_state_housing_product 
      pr_code = loan.product_code
      
      pr_code.in?(["FHA 30 IHCDA IN", "FHA30 IHCDA IN NH", "FHA30 IHDA IL SM", 
                   "FHA30 MSHDA", "MSHDA DPA", "C30FXD IHDA IL", "C30FXD IHDA IL FH", 
                   "FHA30 IHDA IL FH", "MSHDA NH", 'FHA30 GA Dream', 'FHA30 GA CHOICE',
                   'FHA30 GA PEN', 'C30FXD KY HC', 'FHA30 KY HC', 'FHA15STR'])
    end

    def get_flow_result flow_name
      @flow_event = Bpm::LoanValidationEvent.find_by(id: @event_id).loan_validation_flows.find_by(name: flow_name )
      if @flow_event.nil?
        return call_flow_as_fact_type flow_name
      end  
      @flow_event.try(:conclusion)
    end

    def get_date table, column
      date = loan.loan_general.try(table).try(column)
      format_date date
    end
    
    def format_date date
      return nil if date.nil?
      date.to_date.strftime(I18n.t('date.formats.default'))
    end

    def disclosure_request?
      loan.try(:account_info).try(:channel).in?(['A0-Affiliate Standard', 'C0-Consumer Direct Standard', 'P0-Private Banking'])
    end

    def wholesale_request?
      loan.try(:account_info).try(:channel).in?(['W0-Wholesale Standard', 'R0-Reimbursement Standard'])
    end

    def translate_harp val
      FactTranslator.harp_type_of_mi(val)
    end

    def translate_requested_mortgage val
      FactTranslator.requested_mortgage_insurance_type(val)
    end

    def get_custom_field_value formuniq_name, atr_uniq_name
      loan.custom_fields.where(form_unique_name: formuniq_name, attribute_unique_name: atr_uniq_name).first.try(:attribute_value)
    end

    def plus_ten_days req_date, include_sat = true
      BusinessTime::Config.work_week = [:mon, :tue, :wed, :thu, :fri, :sat] if include_sat
      plus_ten = 10.business_days.after(req_date.to_date) 
      BusinessTime::Config.work_week = [:mon, :tue, :wed, :thu, :fri] 
      check_holiday(plus_ten)
    end

    def plus_three_days event_date
      BusinessTime::Config.work_week = [:mon, :tue, :wed, :thu, :fri, :sat]
      plus_three = 3.business_days.after(event_date.to_date) 
      BusinessTime::Config.work_week = [:mon, :tue, :wed, :thu, :fri] 
      check_holiday(plus_three)
    end

    def plus_six_days event_date
      BusinessTime::Config.work_week = [:mon, :tue, :wed, :thu, :fri, :sat]
      plus_six = 6.business_days.after(event_date.to_date) 
      BusinessTime::Config.work_week = [:mon, :tue, :wed, :thu, :fri] 
      check_holiday(plus_six)
    end

    def check_holiday date_holiday
      if date_holiday.to_date.holiday?(:us) || date_holiday.to_date.saturday?
        date_holiday = 0.business_day.after(date_holiday)
      end
      format_date date_holiday
    end

    def gfe_data_lines_for_loan line_num, fee_name
      lines = loan.try(:hud_lines)
      return lines.select{|line| line.sys_fee_name.downcase == fee_name.downcase && line.hud_type == 'GFE'} if loan.trid_loan? || line_num.nil?
      lines.select{|line| line.line_num == line_num && line.sys_fee_name.downcase == fee_name.downcase && line.hud_type == 'GFE'} 
    end

    def hud_data_lines_for_loan fee_name
      lines = loan.try(:hud_lines)
      lines.select{|line| line.sys_fee_name.downcase == fee_name.downcase && line.hud_type == 'HUD'}
    end

    # This function is used for the pre trid loans which uses line number and post trid loans 
    def get_total_amt_rate_perc_from_hud line_num, fee_name, attribute_value, type = "GFE"
      case type
      when 'GFE'
        amount = gfe_data_lines_for_loan(line_num, fee_name).first.try(attribute_value.to_sym)
      when 'HUD'
        amount = hud_data_lines_for_loan(fee_name).first.try(attribute_value.to_sym)
      end
      round_value amount
    end

    def hud_rate_percent line_num, fee_name
      hud_lines_for_number_and_fee(line_num, fee_name).first.try(:rate_perc)
    end

    def return_delivery_method del_code
      case del_code
        when 1
          return 'Email'
        when 2
          return 'Fax'
        when 3
          return 'In Person'
        when 5
          return 'Overnight'
        when 6
          return 'US Mail'
        else
          return nil
      end
    end
  end
end


