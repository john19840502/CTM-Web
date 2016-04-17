app = angular.module('flowAdderService', [])

app.factory 'AddFlow', [ ->
  flowAdderService = []

  filteredFlows = [
    new Validation.FlowResultInfo
      name: "le_box_a"
      title: "LE Box A Acceptance"
      captions: "Determines if the Administration fee is correct based on the product, the Attorney Doc Prep Fees are correct for the state and purpose of loan, and the Discount Percentage is correct if present on the loan."
      def_path: "LE Box A Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "le_box_b"
      title: "LE Box B Acceptance"
      captions: "Determines if the Appraisal Fee, Condo Questionnaire Fee, and Credit Report Fee are complete, and that the Flood Cert Fee is $9."
      def_path: "LE Box B Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "le_box_c"
      title: "LE Box C Acceptance"
      captions: "Determines if the Title Vendor Fee, Pest Inspection Fee, and Survey Fee are complete if applicable."
      def_path: "LE Box C Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "le_box_e_acceptance"
      title: "LE Box E Acceptance"
      captions: "Determines if the Recording fee and Transfer tax fees are correct."
      def_path: "LE Box E Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "le_box_g"
      title: "LE Box G Acceptance"
      captions: "Determines if there is an escrow amount when there is no escrow waiver on the loan."
      def_path: "LE Box G Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "le_box_j_acceptance"
      title: "LE Box J Acceptance"
      captions: "Rule validates the fees in Box J of the LE. The Premium Pricing must match the Lock Premium Pricing. For Private Banking the Premium Pricing and Lock Premium Pricing must be 0."
      def_path: "LE Box J Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "le_page_three"
      title: "LE Page Three Acceptance"
      captions: "Determines if the NMLS information has been completed."
      def_path: "LE Page 3 Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "application_date_compliance"
      title: "Application Date Compliance"
      captions: "Determines if we are disclosing on time and within compliance."
      def_path: "Application Days Compliance.aspx"
    new Validation.FlowResultInfo
      name: "compensation_acceptance"
      title: "Compensation Acceptance"
      captions: "Determines if the Borrower Paid or Lender Paid compensation data is entered correctly, and that premium pricing and a discount amount aren’t both present on a loan."
      def_path: "Compensation Acceptance.aspx"
  ]

  initial_disclosureFlows = [
    new Validation.FlowResultInfo
      name: "arm_gfe_acceptance"
      title: "ARM GFE Acceptance"
      captions: "Determines if the ARM fields within the GFE are complete and accurate for an ARM loan."
      def_path: "ARM GFE Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "arm_rate_lock_acceptance"
      title: "ARM Rate Lock Acceptance"
      captions: "Determines if the ARM Caps are present and correct for the ARM product."
      def_path: "ARM Rate Lock Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "arm_1003_acceptance"
      title: "ARM 1003 Acceptance"
      captions: "Determines if the Caps and Adjustment Periods are present and correct for an ARM loan."
      def_path: "ARM 1003 Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "mortgage_insurance"
      title: "Mortgage Insurance Acceptance"
      captions: "Determines, based on the requested Mortgage Insurance selected, if all the supporting data and coverage is complete and correct."
      def_path: "Mortgage Insurance Acceptance.aspx"
    #new Validation.FlowResultInfo
    #  name: "government_monitoring_acceptance"
    #  title: "Government Monitoring Acceptance"
    #  captions: "Determines that the Government Monitoring section on the 1003 is filled out correctly."
    new Validation.PerformDataCompare
  ]

  info_initial_disclosureFlows = [
    new Validation.FlowResultInfo
      name: "disclosure_method"
      title: "Disclosure Method"
      captions: "Determines if the disclosure method will be CD or LE."
      def_path: "Disclosure Method.aspx"
    new Validation.FlowResultInfo
      name: "va_funding_fee_amt"
      title: "VA Funding Fee Percentage"
      captions: "Calculates the correct VA funding fee amount."
      def_path: "VA Funding Fee Percentage.aspx"
  ]

  registrationFlows = initial_disclosureFlows.concat [
    new Validation.FlowResultInfo
      name: "intent_to_proceed"
      title: "Intent to Proceed Acceptance"
      captions: "Determines if the Intent To Proceed Date is on or after the Initial LE Sent Date."
      def_path: "Intent to Proceed Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "ausreg"
      title: "AUS Registration Acceptance"
      captions: "Determines if the AUS engine is correct for the product."
      def_path: "AUS Registration Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "tbd_policy_acceptance"
      title: "TBD Policy Acceptance"
      captions: "Determines if the loan product is allowed to be registered as a TBD property."
      def_path: "TBD Policy Acceptance.aspx"
  ]

  info_registrationFlows = info_initial_disclosureFlows.concat []

  underwriterFlows = initial_disclosureFlows.concat [
    new Validation.FlowResultInfo
      name: "aus"
      title: "AUS Acceptance"
      captions: "Determines if the AUS engine is correct for the product, and if the underwriting status is acceptable given the AUS response."
      def_path: "AUS Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "asset_acceptance"
      title: "Asset Acceptance"
      captions: "Determines if the borrower has the required funds for the product, and if the LP override reserves amount is less than or equal to the total verified assets."
      def_path: "Asset Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "dti"
      title: "DTI Acceptance"
      captions: "Determines if DTI is within limits for the product."
      def_path: "DTI Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "hpml_compliance"
      title: "HPML Compliance"
      captions: "Determines if an HPML loan’s DTI and FICO limits are acceptable."
      def_path: "HPML Compliance.aspx"
    new Validation.FlowResultInfo
      name: "product_eligibility"
      title: "Product Eligibility"
      captions: "Determines if the product is eligible per its underwriting matrix/guideline, and includes factors such as channel, loan purpose, occupancy, number of units, FICO, LTV, base and total loan amount, county loan limit, etc."
      def_path: "Product Eligibility.aspx"
    new Validation.FlowResultInfo
      name: "project_classification_1008_acceptance"
      title: "Project Classification 1008 Acceptance"
      captions: "Determines if the Project Classification selected is acceptable for the loan product and property type."
      def_path: "Project Classification 1008 Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "escrow_waiver_acceptance"
      title: "Escrow Acceptance"
      captions: "Determines if the current escrow waiver indicator of yes or no is acceptable given the product, state and LTV."
      def_path: "Escrow Waiver Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "documents_expiration_dates_acceptance"
      title: "Documents Expiration Dates Acceptance"
      captions: "Determines if the documents such as appraisal, assets, credit docs, credit report, income, and title commitment do not expire before a loan’s closing."
      def_path: "Documents Expiration Dates Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "florida_condo_acceptance"
      title: "Florida Condo Acceptance"
      captions: "Is the project classification and PERS List information filled out correctly?  Does this loan require more restrictive Florida Condo guidelines?  Is the product eligible per its underwriting matrix/guidelines?"
      def_path: "Florida Condo Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "credit_score_comparison_acceptance"
      title: "Credit Score Comparison Acceptance"
      captions: "Determines if the borrower and co-borrower(s) credit score(s) match across the lock screen, underwriter conditions/decision screen, and the credit report (downloaded scores)."
      def_path: "Credit Score Comparison Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "appraisal_acceptance"
      title: "Appraisal Acceptance"
      captions: "Determines if the appraisal data such as the appraiser name and license, year built, value, and type have been completed correctly."
      def_path: "Appraisal Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "other_data_1003"
      title: "Other Data 1003 Acceptance"
      captions: "Determines if a PUD property is marked correctly and if a Freddie Relief product has the correct Offering Identifier selection."
      def_path: "Other Data 1003 Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "texas_50a6_acceptance"
      title: "Texas 50A6 Acceptance"
      captions: "Rule is checking that if the loan is a Texas 50A6 it meets the proper loan requirements."
      def_path: "Texas 50A6 Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "general_eligibility"
      title: "General Eligibility"
      captions: "Determines if the product is eligible per general guidelines, like property state, property type, etc."
      def_path: "General Eligibility.aspx"
    #new Validation.FlowResultInfo
    #  name: "max_cash_back_acceptance"
    #  title: "Max Cash Back Acceptance"
    #  captions: "Determines if the total cash back on a loan exceeds guidelines for the product and purpose."
    #  def_path: "Max Cash Back Acceptance.aspx"
  ]

  info_underwriterFlows = info_registrationFlows.concat []

  preclosingFlows = underwriterFlows.concat [
    new Validation.FlowResultInfo
      name: "rate_lock_expiration_dates"
      title: "Rate Lock Expiration Dates Acceptance"
      captions: "Determines if the lock is or will be good through funding."
      def_path: "Rate Lock Expiration Dates Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "insurance_documents_acceptance"
      title: "Insurance Documents Acceptance"
      captions: "Determines if the HOI and Flood effective dates and Expiration dates are good relative to the loan's closing date."
      def_path: "Insurance Documents Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "preclosing"
      title: "PreClosing Acceptance"
      captions: "Determines if the closing and funding dates are acceptable based on state, loan purpose, occupancy, and loan status."
      def_path: "PreClosing Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "closing_date"
      title: "Closing Date Acceptance"
      captions: "Determines if the closing date is acceptable based on the Minimum and Maximum closing dates and a Fee Tolerance date (if applicable.)"
      def_path: "Closing Date Acceptance.aspx"
  ]

  info_preclosingFlows = info_underwriterFlows.concat [
    new Validation.FlowResultInfo
      name: "minimum_closing_date"
      title: "Minimum Closing Date"
      captions: "Calculates the earliest acceptable closing date."
      def_path: "Minimum Closing Date.aspx"
    new Validation.FlowResultInfo
      name: "maximum_closing_date"
      title: "Maximum Closing Date"
      captions: "Calculates the latest acceptable closing date."
      def_path: "Maximum Closing Date.aspx"
    new Validation.FlowResultInfo
      name: "closing_verification_date_acceptance"
      title: "Closing Verification Date Acceptance"
      captions: "Determines if the closing verification date, which is the earliest expiration date of the VOE, MERS, OFAC, and LQI, is on or after the closing date."
      def_path: "Closing Verification Date Acceptance.aspx"
    new Validation.FlowResultInfo
      name: "determine_cd_recipients"
      title: "Determine CD Recipients"
      captions: "Determines which parties should receive the CD, primary borrower or all vested parties."
      def_path: "Determine CD Recipients.aspx"
  ]

  closingFlows = preclosingFlows.concat [
    new Validation.FlowResultInfo
      name: "ratio_change_acceptance"
      title: "Ratio Change Acceptance"
      captions: "Determines if the taxes and insurance values have changed more than the allowable threshold from underwriting to closing."
      def_path: "Ratio Change Acceptance.aspx"
  ]

  info_closingFlows = info_preclosingFlows.concat []

  flowAdderService.adder = (type) -> 
    switch (type)
      when 'initial_disclosure'
        filteredFlows.concat(initial_disclosureFlows)
      when 'registration'
        registrationFlows
      when 'underwriter'
        underwriterFlows
      when 'preclosing'
        preclosingFlows
      when 'closing'
        closingFlows
      when 'info_initial_disclosure'
        info_initial_disclosureFlows
      when 'info_registration'
        info_registrationFlows
      when 'info_underwriter'
        info_underwriterFlows
      when 'info_preclosing'
        info_preclosingFlows
      when 'info_closing'
        info_closingFlows

    
  return flowAdderService
]
  
