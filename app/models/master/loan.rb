require 'ctm/ms_sql_view'
module Master
  class Loan < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView

    attr_accessible :purpose_type, :loan_amortization_type

    from 'LOAN_GENERAL', as: 'lg'

    # relations
    has_many :assets, class_name: 'Master::Asset', inverse_of: :loan
    has_many :boarding_files, through: :loan_boardings
    has_many :borrowers, class_name: 'Master::Person::Borrower'
    has_many :calculations, class_name: 'Master::LoanDetails::Calculation'
    has_many :compliance_alerts, class_name: 'Master::ComplianceAlert', inverse_of: :loan
    has_many :credit_reports, class_name: 'Master::CreditReport', inverse_of: :loan
    has_many :custom_fields, primary_key: :id, foreign_key: :loan_general_id
    has_many :loan_events, primary_key: :id, foreign_key: :loan_general_id
    has_many :down_payments, class_name: 'Master::DownPayment', inverse_of: :loan
    has_many :employers, class_name: 'Master::Employer'
    has_many :escrow_disbursement_types, class_name: 'Master::EscrowDisbursementType', inverse_of: :loan
    has_many :escrow_disbursements, class_name: 'Master::EscrowDisbursement', inverse_of: :loan
    has_many :escrows, class_name: 'Master::Escrow', inverse_of: :loan
    has_many :hud_lines, class_name: 'Master::HudLine'
    has_many :income_sources, class_name: 'Master::IncomeSource', inverse_of: :loan
    has_many :investor_delivery_units, class_name: 'Master::InvestorDeliveryUnit', inverse_of: :loan
    has_many :legal_descriptions, class_name: 'Master::LegalDescription', inverse_of: :loan
    has_many :liabilities, class_name: 'Master::Liability'
    has_many :loan_boardings, primary_key: :loan_num
    has_many :loan_notes_notes, primary_key: :id, foreign_key: :loan_general_id
    has_many :current_incomes, primary_key: :id, foreign_key: :loan_general_id
    has_many :mi_renewal_premiums, class_name: 'Master::MiRenewalPremium', inverse_of: :loan
    has_many :payment_occurrences, class_name: 'Master::PaymentOccurrence', inverse_of: :loan
    has_many :proposed_housing_expenses, class_name: 'Master::ProposedHousingExpense', inverse_of: :loan
    has_many :reo_properties, class_name: 'Master::ReoProperty', inverse_of: :loan, primary_key: :id, foreign_key: :loan_id
    has_many :residences, class_name: 'Master::Residence'
    has_many :shippings, class_name: 'Master::Shipping'
    has_many :special_feature_codes, class_name: 'Master::SpecialFeatureCode', inverse_of: :loan
    has_many :comments, class_name: 'LoanCommentHistory', primary_key: :loan_num, foreign_key: :loan_num

    has_one  :custom_loan_data, class_name: 'Master::LoanDetails::CustomLoanData', inverse_of: :loan, primary_key: :loan_num, foreign_key: :loan_num
    has_one  :initial_disclosure_tracking, primary_key: :loan_num, foreign_key: :loan_num
    has_one  :disclosure_request_timestamp, primary_key: :loan_num, foreign_key: :loan_number, class_name: "Master::DisclosureRequestTimestamp"
    
    belongs_to :branch, class_name: 'Institution', foreign_key: :institution_identifier, primary_key: :institution_number
    belongs_to :originator, class_name: 'BranchEmployee', foreign_key: :broker_identifier, primary_key: :username

    def self.trid_loans
      where { application_date >= TRID_DATE }
    end

    # prediction:  this will come back to haunt me
    RETAIL_CHANNELS_WITH_TEST = Channel.retail_all_ids.concat(["TA0-Test Affiliate Standard", "TP0-Test Private Banking channels", "TC0-Test Consumer Direct Standard" ])

    WHOLESALE_CHANNELS_WITH_TEST = [ "TW0-Test Wholesale Standard", Channel.wholesale.identifier ]
    scope :all_retail_with_test, ->{ where(channel: RETAIL_CHANNELS_WITH_TEST) }
    scope :wholesale_with_test, ->{ where(channel: WHOLESALE_CHANNELS_WITH_TEST )  }

    scope :all_retail, ->{ where(channel: Channel.retail_all_ids) }
    scope :wholesale, ->{ where(channel: Channel.wholesale.identifier)  }
    # This should catch "Test" loans too, which we need for testing forced registration
    scope :all_but_mini_corr, ->{ where("channel NOT LIKE '%Reimbursement%'") }
    scope :loans_not_submitted_within, ->(days_ago) { joins(:custom_fields).where{ (pipeline_loan_status_description.in ['File Received', 'New', 'Imported', 'In Process']) }.merge(CustomField.intent_to_proceed days_ago) }

    def self.has_six_pieces
      subquery = CurrentIncome.group(:loan_general_id).
        where{ income_type == 'Base' }.
        select{ [ loan_general_id, sum(monthly_total_amount).as('amt') ] }

      joins{[
        borrowers,
        subquery.as('total_income').on { id == total_income.loan_general_id } 
      ]}.
      where{
        ((property_address != '') & (property_address != "TBD")) &
        ((property_city != '') & (property_city != "TBD")) &
        ((property_state != '') & (property_state != "TBD")) &
        ((property_postal_code != '') & (property_postal_code != "TBD")) &
        (base_loan_amount > 0) &
        (total_income.amt > 0) &
        ((td_property_estimated_value_amount > 0) | (td_property_appraised_value_amount > 0)) &
        ((borrowers.borrower_id == 'BRW1') &
         (borrowers.last_name != '') &
         (borrowers.ssn != '')) 
      }
    end

    def self.no_app_date
      where{ application_date == nil }
    end

    def self.created_post_trid
      where { application_created_at >= TRID_DATE }
    end

    # fields
    field :id,                                                            column: 'loanGeneral_id'
    field :loan_num,                                                      column: 'LenderRegistrationIdentifier'
    field :agency_case_identifier,                                        column: 'AgencyCaseIdentifier',                       source: 'MT'
    field :amortization_term,                                             column: 'LoanAmortizationTermMonths',                 source: 'MT'
    field :app_received_on,                                               column: 'ApplicationReceivedDate',                    source: 'GFED'
    field :appraised_on,                                                  column: 'AppraisalDate',                              source: 'UD'
    field :apr_rate,                                                      column: 'APR',                                        source: 'ALD'
    field :account_executive_name,                                        column: 'AccountExecutiveName',                       source: 'ALD'
    field :arm_ceiling_rate,                                              column: 'GFEMaxRate',                                 source: 'GFED'
    field :arm_floor_rate,                                                column: '_LifetimeFloorPercent',                      source: 'ARM'
    field :arm_margin_rate,                                               column: '_IndexMarginPercent',                        source: 'ARM'
    field :base_index_margin,                                             column: 'BaseIndexMargin',                            source: 'LP'
    field :base_loan_amount,                                              column: 'BaseLoanAmount',                             source: 'MT'
    field :borrower_paid_discount_points,                                 column: 'BorrowerPaidDiscountPointsTotalAmount',      source: 'TD'
    field :broker_email_address,                                          column: 'BrokerEmailAddress',                         source: 'AI'
    field :broker_first_name,                                             column: 'BrokerFirstName',                            source: 'AI'
    field :broker_identifier,                                             column: 'BrokerIdentifier',                           source: 'AI'
    field :broker_last_name,                                              column: 'BrokerLastName',                             source: 'AI'
    field :cancelled_or_withdrawn_at,                                     column: '_CancelWithdrawnDate',                       source: 'DLTR'
    field :census_tract,                                                  column: 'CensusTract',                                source: 'FD'
    field :channel,                                                       column: 'Channel',                                    source: 'AI'
    field :closing_on,                                                    column: 'ClosingDate',                                source: 'LD'
    field :cltv,                                                          column: 'CLTV',                                       source: 'LLD'
    field :county_code,                                                   column: '_CountyCode',                                source: 'PRPTY'
    field :cpm_id,                                                        column: 'AttributeValue',                             source: 'CPM'
    field :debt_to_income_ratio,                                          column: 'DebtToIncomeRatio',                          source: 'LLD'
    field :denial_mailed_date,                                            column: '_MailedDate',                                source: 'DLTR'
    field :denied_at,                                                     column: '_DeniedDate',                                source: 'DLTR'
    field :document_preparation_date,                                     column: 'DocumentPreparationDate',                    source: 'LD'
    field :employee_loan_indicator,                                       column: 'EmployeeLoanIndicator',                      source: 'ALD'
    field :escrow_waiver_indicator,                                       column: 'EscrowWaiverIndicator',                      source: 'LLD'
    field :estimated_closing_costs_amount,                                column: 'EstimatedClosingcostsAmount',                source: 'TD'
    field :excluded_from_hmda_on,                                         column: 'ExcludedFromHMDADate',                       source: 'DLTR'
    field :features_payment_frequency_type,                               column: 'PaymentFrequencyType',                       source: 'FEATURES'
    field :fha_case_identifier,                                           column: 'OriginalFHACaseIdentifier',                  source: 'FHAOL'
    field :fha_coverage_renewal_rate,                                     column: 'FHACoverageRenewalRatePercent',              source: 'FHAL'
    field :fieldwork_obtained,                                            column: 'FieldworkObtained',                          source: 'TRANS'
    field :td_property_appraised_value_amount,                            column: 'PropertyAppraisedValueAmount',               source: 'TRANS'
    field :td_property_estimated_value_amount,                            column: 'PropertyEstimatedValueAmount',               source: 'TRANS'
    field :final_note_rate,                                               column: 'FinalNoteRate',                              source: 'LP'
    field :fips_county,                                                   column: 'CountyCode',                                 source: 'FD'
    field :fips_state,                                                    column: 'StateCode',                                  source: 'FD'
    field :first_change_cap_rate,                                         column: '_FirstChangeCapRate',                        source: 'RA'
    field :first_payment_on,                                              column: 'ScheduledFirstPaymentDate',                  source: 'FEATURES'
    field :first_payment_change_date,                                     column: 'FirstPaymentChangeDate',                     source: 'ALLPORP'
    field :first_rate_adjustment_date,                                    column: 'FirstRateAdjustmentDate',                    source: 'RA'
    field :first_time_homebuyer_indicator,                                column: 'FirstTimeHomebuyer',                         source: 'LLD'
    field :flood_certification_company_name,                              column: 'FloodCompanyName',                           source: 'FD'
    field :flood_certification_identifier,                                column: 'FloodCertificationIdentifier',               source: 'FD'
    field :flood_determination_date,                                      column: 'FloodDeterminationDate',                     source: 'FD'
    field :flood_determination_nfip_community_identifier,                 column: 'NFIPCommunityIdentifier',                    source: 'FD'
    field :flood_determination_nfip_community_participation_status_type,  column: 'NFIPCommunityParticipationStatusType',       source: 'FD'
    field :flood_determination_nfip_flood_zone_identifier,                column: 'NFIPFloodZoneIdentifier',                    source: 'FD'
    field :flood_determination_nfip_map_identifier,                       column: 'NFIPMapIdentifier',                          source: 'FD'
    field :flood_hazard_area,                                             column: 'SpecialFloodHazardAreaIndicator',            source: 'FD'
    field :flood_insurance_policy_number,                                 column: 'FloodInsurancePolicyIdentifier',             source: 'CI'
    field :funded_at,                                                     column: '_FundedDate',                                source: 'FUND'
    field :grace_period,                                                  column: '_GracePeriod',                               source: 'LCHRG'
    field :trid_grace_period,                                             column: 'GracePeriod',                                source: 'PROD'
    field :late_charge_percentage,                                        column: 'Percentage',                                 source: 'PROD'
    field :gse_property_type,                                             column: 'GSEPropertyType',                            source: 'FEATURES'
    field :gse_refinance_purpose_type,                                    column: 'GSERefinancePurposeType',                    source: 'LLD'
    field :hazard_insurance_policy_number,                                column: 'HazardInsurancePolicyIdentifier',            source: 'CI'
    field :initial_gfe_disclosure_on,                                     column: 'InitialGFEDIsclosureDate',                   source: 'GFED'
    field :initial_lock_performed_on,                                     column: 'InitialLockPerformedDate',                   source: 'LLD'
    field :institution_id,                                                column: 'INSTITUTION_Id',                             source: 'AI'
    field :institution_identifier,                                        column: 'InstitutionIdentifier',                      source: 'AI'
    field :insured_on,                                                    column: '_InsuredDate',                               source: 'IG'
    field :interviewer_application_signed_at,                             column: 'InterviewerApplicationSignedDate',           source: 'II'
    field :interviewer_telephone,                                         column: 'InterviewersTelephoneNumber',                source: 'II'
    field :invblock_attr_val,                                             column: 'AttributeValue',                             source: 'INVBLK'
    field :investor_name,                                                 column: 'InvestorName',                               source: 'IL'
    field :intent_to_proceed,                                             column: 'IntentToProceed',                            source: 'GFED'
    field :last_submitted_au_recommendation,                              column: 'LastSubmittedAURecommendation',              source: 'TRANS'
    field :late_charge_rate,                                              column: '_Rate',                                      source: 'LCHRG'
    field :lender_paid_mi,                                                column: 'LenderPaidMI',                               source: 'LLD'
    field :loan_amortization_type,                                        column: 'LoanAmortizationType',                       source: 'MT'
    field :lock_commitment_reference_id,                                  column: 'CommitmentReferenceIdentifier',              source: 'IL'
    field :locked_at,                                                     column: 'LockDate',                                   source: 'LP'
    field :lock_expiration_at,                                            column: 'LockExpirationDate',                         source: 'LP'
    field :mature_on,                                                     column: 'LoanMaturityDate',                           source: 'LD'
    field :mers_originating_org_id,                                       column: '_MERSDataOriginatingOrgId',                  source: 'MERS'
    field :mers_registration_date,                                        column: '_MINRegistrationDate',                       source: 'MERS'
    field :mers_registration_flag,                                        column: '_RegistrationIndicator',                     source: 'MERS'
    field :mi_and_funding_fee_financed_amount,                            column: 'MIAndFundingFeeFinancedAmount',              source: 'TD'
    field :mi_certificate_id,                                             column: 'MICertificateIdentifier',                    source: 'MIDA'
    field :mi_company_id,                                                 column: 'MICompanyId_1003',                           source: 'MIDA'
    field :mi_company_name,                                               column: 'MICompanyName',                              source: 'MIDA'
    field :mi_coverage_percent,                                           column: 'MICoveragePercent1003',                      source: 'MIPHE'
    field :mi_fha_upfront_premium_amt,                                    column: 'MI_FHAUpfrontPremiumAmount',                 source: 'MIDA'
    field :mi_indicator,                                                  column: 'MIIndicator',                                source: 'LLD'
    field :mi_initial_premium_term_months,                                column: 'MIInitialPremiumRateDurationMonths',         source: 'MIDA'
    field :mi_lender_paid_rate_percent,                                   column: 'MILenderPaidRatePercent',                    source: 'MIDA'
    field :mi_percentage_covered,                                         column: 'MICoveragePercent',                          source: 'LLD'
    field :mi_premium_from_closing_amt,                                   column: 'MIPremiumFromClosingAmount',                 source: 'MIDA'
    field :mi_program,                                                    column: 'MIProgram_1003',                             source: 'MIDA'
    field :mi_scheduled_termination_date,                                 column: 'MIScheduledTerminationDate',                 source: 'MIDA'
    field :min_number,                                                    column: '_MINNumber',                                 source: 'MERS'
    field :mortgage_type,                                                 column: 'MortgageType',                               source: 'MT'
    field :msa_identifier,                                                column: 'MSAIdentifier',                              source: 'AL'
    field :net_price,                                                     column: 'NetPrice',                                   source: 'LP'
    field :new_construction,                                              column: 'NewConstruction',                            source: 'LLD'
    field :number_of_units,                                               column: '_FinancedNumberOfUnits',                     source: 'PRPTY'
    field :original_balance,                                              column: 'TotalLoanAmount',                            source: 'LLD'
    field :original_ltv,                                                  column: 'LTV',                                        source: 'LLD'
    field :original_mi_period_months,                                     column: 'OriginalMortgageInsurancePeriodMonthsCount', source: 'FHAOL'
    field :payment_amount,                                                column: '_PaymentAmount',                             source: 'MIPHE'
    field :pipeline_loan_status_description,                              column: 'PipelineLoanStatusDescription',              source: 'ALD'
    field :pipeline_lock_status_description,                              column: 'PipelineLockStatusDescription',              source: 'ALD'
    field :application_created_at,                                        column: 'ApplicationCreationDateTimeInAvista',        source: 'ALD'
    field :prepayment_penalty_indicator,                                  column: 'Prepay',                                     source: 'LLD'
    field :principal_and_interest_payment,                                column: '_PaymentAmount',                             source: 'FMPAI'
    field :prodcd_attr_val,                                               column: 'AttributeValue',                             source: 'PRODCD'
    field :product_code,                                                  column: 'ProductCode',                                source: 'LP'
    field :product_code_uw,                                               column: 'ProductCode',                                source: 'UD'
    field :product_name,                                                  column: 'ProductName',                                source: 'FEATURES'
    field :project_name,                                                  column: 'ProjectName',                                source: 'DET'
    field :property_address,                                              column: '_StreetAddress',                             source: 'PRPTY'
    field :property_appraised_amt,                                        column: 'PropertyAppraisedValueAmount',               source: 'LLD'
    field :property_city,                                                 column: '_City',                                      source: 'PRPTY'
    field :property_county,                                               column: '_County',                                    source: 'PRPTY'
    field :property_postal_code,                                          column: '_PostalCode',                                source: 'PRPTY'
    field :property_state_gfe,                                            column: 'PropertyState',                              source: 'GLD'
    field :property_state_lld,                                            column: 'PropertyState',                              source: 'LLD'
    field :property_state,                                                column: '_State',                                     source: 'PRPTY'
    field :property_usage_type,                                           column: 'PropertyUsageType',                          source: 'PURP'
    field :property_usage_type_2,                                         column: 'PropertyUsageType',                          source: 'LLD'
    field :purchase_price,                                                column: 'PurchasePriceAmount',                        source: 'TD'
    field :purpose_type,                                                  column: '_Type',                                      source: 'PURP'
    field :rate_adjustment_lifetime_cap_percent,                          column: 'RateAdjustmentLifetimeCapPercent',           source: 'ARM'
    field :rep_credit_score,                                              column: 'RepresentativeCreditScore',                  source: 'UD'
    field :rep_fico_score,                                                column: 'RepresentativeFICOScore',                    source: 'LLD'
    field :req_int_rate,                                                  column: 'RequestedInterestRatePercent',               source: 'GLD'
    field :seller_paid_closing_costs_amount,                              column: 'SellerPaidClosingCostsAmount',               source: 'TD'
    field :special_flood_hazard_area_indicator,                           column: 'SpecialFloodHazardAreaIndicator',            source: 'FD'
    field :structure_built_year,                                          column: '_StructureBuiltYear',                        source: 'PRPTY'
    field :term,                                                          column: 'LoanAmortizationTermMonths',                 source: 'GLD'
    field :loan_amortization_term,                                        column: 'LoanAmortizationTermMonths',                 source: 'LLD'                                        
    field :application_date,                                              column: 'ApplicationDate',                            source: 'CA'
    field :escrow_aggregate_accounting_adjustment_amount,                 column: 'EscrowAggregateAccountingAdjustmentAmount',  source: 'EAS'
    field :escrow_waiver_indicator,                                       column: 'EscrowWaiverIndicator',                      source: 'LLD'

    # use to alias existing attributes, or for fields that are pulled twice in views.
    alias_attribute :amortization_type, :loan_amortization_type
    alias_attribute :appl_date, :app_received_on
    alias_attribute :hud_original_base_loan_amount, :base_loan_amount
    alias_attribute :institution_id, :institution_identifier
    alias_attribute :inv_loan_num, :loan_num
    alias_attribute :loan_general_id, :id
    alias_attribute :maturity_date, :mature_on
    alias_attribute :mers_number, :min_number
    alias_attribute :original_bal, :original_balance
    alias_attribute :pmi_case_number, :mi_certificate_id
    alias_attribute :principal_balance, :original_balance
    alias_attribute :requested_interest_rate_percent, :req_int_rate

    # joins that should be included as part of loan
    join 'ACCOUNT_INFO',                on: 'loanGeneral_Id', as: 'AI',       type: :left_outer
    join 'ADDITIONAL_LOAN_DATA',        on: 'loanGeneral_Id', as: 'ALD',      type: :left_outer
    join 'AFFORDABLE_LENDING',          on: 'loanGeneral_Id', as: 'AL',       type: :left_outer
    join 'ALL_PROPERTIES_LOAN_TYPES',   on: 'loanGeneral_Id', as: 'ALLPORP',  type: :left_outer
    join 'ARM',                         on: 'loanGeneral_Id', as: 'ARM',      type: :left_outer
    join 'CLOSING_INSTRUCTIONS',        on: 'loanGeneral_Id', as: 'CI',       type: :left_outer
    join 'COMPLIANCE_ALERTS',           on: 'loanGeneral_Id', as: 'CA',       type: :left_outer
    join 'CUSTOM_FIELD',                on: 'loanGeneral_Id', as: 'INVBLK',   type: :left_outer, and: {'AttributeUniqueName' => 'LOI Block #'}
    join 'CUSTOM_FIELD',                on: 'loanGeneral_Id', as: 'PRODCD',   type: :left_outer, and: {'AttributeUniqueName' => 'LOI Prod Code'}
    join 'CUSTOM_FIELD',                on: 'loanGeneral_Id', as: 'CPM',      type: :left_outer, and: {'AttributeUniqueName' => 'PERS ID'}
    join 'DENIAL_LETTER',               on: 'loanGeneral_Id', as: 'DLTR',     type: :left_outer
    join '_DETAILS',                    on: 'loanGeneral_Id', as: 'DET',      type: :left_outer
    join 'FHA_ORIGINAL_LOAN',           on: 'loanGeneral_Id', as: 'FHAOL',    type: :left_outer
    join 'FHA_LOAN',                    on: 'loanGeneral_Id', as: 'FHAL',     type: :left_outer
    join 'FLOOD_DETERMINATION',         on: 'loanGeneral_Id', as: 'FD',       type: :left_outer
    join 'FUNDING_DATA',                on: 'loanGeneral_Id', as: 'FUND',     type: :left_outer
    join 'GFE_DETAIL',                  on: 'loanGeneral_Id', as: 'GFED',     type: :left_outer
    join 'GFE_LOAN_DATA',               on: 'loanGeneral_Id', as: 'GLD',      type: :left_outer
    join 'INSURING_AND_GUARANTEEING',   on: 'loanGeneral_Id', as: 'IG',       type: :left_outer
    join 'INTERVIEWER_INFORMATION',     on: 'loanGeneral_Id', as: 'II',       type: :left_outer
    join 'INVESTOR_LOCK',               on: 'loanGeneral_Id', as: 'IL',       type: :left_outer
    join 'LATE_CHARGE',                 on: 'loanGeneral_Id', as: 'LCHRG',    type: :left_outer
    join 'LOAN_DETAILS',                on: 'loanGeneral_Id', as: 'LD',       type: :left_outer
    join 'LOAN_FEATURES',               on: 'loanGeneral_Id', as: 'FEATURES', type: :left_outer
    join 'LOAN_PURPOSE',                on: 'loanGeneral_Id', as: 'PURP',     type: :left_outer
    join 'LOCK_LOAN_DATA',              on: 'loanGeneral_Id', as: 'LLD',      type: :left_outer
    join 'LOCK_PRICE',                  on: 'loanGeneral_Id', as: 'LP',       type: :left_outer
    join 'MERS',                        on: 'loanGeneral_Id', as: 'MERS',     type: :left_outer
    join 'MI_DATA',                     on: 'loanGeneral_Id', as: 'MIDA',     type: :left_outer
    join 'MORTGAGE_TERMS',              on: 'loanGeneral_Id', as: 'MT',       type: :left_outer
    join 'PROPERTY',                    on: 'loanGeneral_Id', as: 'PRPTY',    type: :left_outer
    join 'PROPOSED_HOUSING_EXPENSE',    on: 'loanGeneral_Id', as: 'FMPAI',    type: :left_outer, and: {'HousingExpenseType' => 'FirstMortgagePrincipalAndInterest'}
    join 'PROPOSED_HOUSING_EXPENSE',    on: 'loanGeneral_Id', as: 'MIPHE',    type: :left_outer, and: {'HousingExpenseType' => 'MI'}
    join 'RATE_ADJUSTMENT',             on: 'loanGeneral_Id', as: 'RA',       type: :left_outer
    join 'TRANSACTION_DETAIL',          on: 'loanGeneral_Id', as: 'TD',       type: :left_outer
    join 'TRANSMITTAL_DATA',            on: 'loanGeneral_Id', as: 'TRANS',    type: :left_outer
    join 'UNDERWRITING_DATA',           on: 'loanGeneral_Id', as: 'UD',       type: :left_outer
    join 'ESCROW_ACCOUNT_SUMMARY',      on: 'loanGeneral_Id', as: 'EAS',      type: :left_outer
    join 'LOCK_LOAN_DATA',              on: 'loanGeneral_Id', as: 'LLD',      type: :left_outer

    join 'PRODUCT',                     on: ['LP.ProductCode', 'PROD.ProductCode'],  as: 'PROD', type: :left_outer

    # joins
    #join 'BORROWER', on: ['c.CALCULATION_id', 'ai.LoanGeneralId'], as: 'ai', type: :inner

    # will produce c.LoanGeneralId = ai.LoanGeneralId
    #join 'BORROWER', on: 'loanGeneral_Id', as: 'BRW1', type: :left_outer, and: {'BorrowerID' => 'BRW1'}
    #join 'BORROWER', on: 'loanGeneral_Id', as: 'BRW2', type: :left_outer, and: {'BorrowerID' => 'BRW2'}

    # # used to build out the view for datamart.
    def self.sqlserver_create_view
      self.build_query
    end

    def closer_cd_flag
      flag = self.try(:custom_loan_data).try(:disclose_by_cd_user_uuid)
      flag.nil? ? "No" : "Yes"
    end

    def credit_report_identifier
      credit_reports.where(borrower_position: '1').last.try(:credit_report_identifier)
    end

    def lowest_fico_score
      return rep_fico_score unless borrowers.present?
      scores = borrowers.order(:borrower_id).uniq(&:borrower_id).map(&:credit_score).uniq.compact.sort
      return scores.first if scores.present?
      return rep_fico_score
    end

    def primary_borrower
      borrowers.primary
    end

    def secondary_borrower
      borrowers.secondary
    end

    def first_mi_renewal_premium
      mi_renewal_premiums.first_premium
    end

    def is_primary_residence?
      type = property_usage_type_2.present? ? property_usage_type_2 : property_usage_type
      type == 'PrimaryResidence'
    end

    delegate :gender_type, :hmda_ethnicity_type, :hmda_race_type, :marital_status_type, to: :primary_borrower, allow_nil: true, prefix: 'primary'
    delegate :gender_type, :hmda_ethnicity_type, :hmda_race_type, :marital_status_type, to: :secondary_borrower, allow_nil: true, prefix: 'secondary'

    def coborrowers
      # anything other than primary/secondary
      borrowers.coborrowers
    end

    def lpmi_percentage
      Smds::LpmiCoveragePercentage.percent(original_ltv, loan_amortization_term)
    end

    def is_fha?
      product_name.starts_with?('FHA')
    end

    def is_arm?
      loan_amortization_type.present? && loan_amortization_type.downcase == 'adjustablerate'
    end

    def is_condo?
      gse_property_type.in?(['Condominium', 'DetachedCondominium', 'HighRiseCondominium'])
    end

    def is_portfolio_loan?
      flg = Smds::PortfolioTrackingFlag.where(channel: channel, product_code: product_code).
        where('beg_portfolio_on <= ? and end_portfolio_on >= ?', initial_lock_performed_on.try(:beginning_of_day), initial_lock_performed_on.try(:beginning_of_day))
      return true unless flg.empty?
      return false
    end

    def port_loan_fas91_params
      Smds::PortLoanFas91Parms.
        where(channel: channel).
        where('begin_on <= :funded_at and end_on >= :funded_at', funded_at: funded_at).
        first
    end

    def original_deferred_fee_amount
      if trid_loan?
        Calculator::CalculateOriginalDeferredFee.for(self)
      else
        original_deferred_fee_amount_pre_trid
      end
    end

    def original_deferred_fee_amount_pre_trid
      @connection = ActiveRecord::Base.connection
      result = @connection.exec_query(
        <<-eos
          select 0 - isnull(hl802._TotalAmount,0) - isnull(hl801._TotalAmount,0) 
          - isnull(hl811._TotalAmount,0) - isnull(hl812._TotalAmount,0) 
          - isnull(hl813._TotalAmount,0) + isnull(hl808._TotalAmount,0) 
          + isnull(hl826._TotalAmount,0) + isnull(hl827._TotalAmount,0) 
          + round(isnull(lld.TotalLoanAmount,0) * fas91.DeferredWholesaleCommPct, 2) 
          + fas91.DeferredRetailCommAmt + fas91.SalaryAndBenefitsAmt 
          + fas91.LoanLevelCostsAmt as NetDeferral
          from LENDER_LOAN_SERVICE.dbo.LOAN_GENERAL lg
          join LENDER_LOAN_SERVICE.dbo.FUNDING_DATA fd on lg.loanGeneral_Id = fd.loanGeneral_Id
          LEFT outer join LENDER_LOAN_SERVICE.dbo.DENIAL_LETTER dl on lg.loanGeneral_Id = dl.loanGeneral_Id
          join LENDER_LOAN_SERVICE.dbo.LOCK_LOAN_DATA lld on lg.loanGeneral_Id = lld.loanGeneral_Id
          join LENDER_LOAN_SERVICE.dbo.ACCOUNT_INFO ai on lg.loanGeneral_Id = ai.loanGeneral_Id
          join LENDER_LOAN_SERVICE.dbo.UNDERWRITING_DATA ud on lg.loanGeneral_Id = ud.loanGeneral_Id
          join CTM.smds.SMDSPortfolioTrackingFlag ptf on ud.ProductCode = ptf.ProductCode and ai.Channel = ptf.Channel and cast(lld.InitialLockPerformedDate as date) >= ptf.BegPortfolioDt and cast(lld.InitialLockPerformedDate AS DATE) <= ptf.EndPortfolioDt
          join CTM.smds.SMDSPortLoanFAS91Parms fas91 on ai.Channel = fas91.Channel and fas91.BeginDt <= fd._FundedDate and fas91.EndDt >= fd._FundedDate 
          left outer join LENDER_LOAN_SERVICE.dbo.HUD_LINE hl802 on hl802.loanGeneral_Id = lg.loanGeneral_Id and hl802.hudType = 'HUD' and hl802._LineNumber = '802' and hl802.NetFeeIndicator = '1'
          left outer join LENDER_LOAN_SERVICE.dbo.HUD_LINE hl801 on hl801.loanGeneral_Id = lg.loanGeneral_Id and hl801.hudType = 'HUD' and hl801._LineNumber = '801' and hl801.NetFeeIndicator = '1'
          left outer join LENDER_LOAN_SERVICE.dbo.HUD_LINE hl811 on hl811.loanGeneral_Id = lg.loanGeneral_Id and hl811.hudType = 'HUD' and hl811._LineNumber = '811' and hl811.NetFeeIndicator = '1' and hl811._UserDefinedFeeName like 'ADMIN%'
          left outer join LENDER_LOAN_SERVICE.dbo.HUD_LINE hl812 on hl812.loanGeneral_Id = lg.loanGeneral_Id and hl812.hudType = 'HUD' and hl812._LineNumber = '812' and hl812.NetFeeIndicator = '1' and hl812._UserDefinedFeeName like 'ADMIN%'
          left outer join LENDER_LOAN_SERVICE.dbo.HUD_LINE hl813 on hl813.loanGeneral_Id = lg.loanGeneral_Id and hl813.hudType = 'HUD' and hl813._LineNumber = '813' and hl813.NetFeeIndicator = '1' and hl813._UserDefinedFeeName like 'ADMIN%'
          left outer join LENDER_LOAN_SERVICE.dbo.HUD_LINE hl808 on hl808.loanGeneral_Id = lg.loanGeneral_Id and hl808.hudType = 'HUD' and hl808._LineNumber = '808' and hl808.NetFeeIndicator = '1'
          left outer join LENDER_LOAN_SERVICE.dbo.HUD_LINE hl826 on hl826.loanGeneral_Id = lg.loanGeneral_Id and hl826.hudType = 'HUD' and hl826._LineNumber = '826' and hl826.NetFeeIndicator = '1'
          left outer join LENDER_LOAN_SERVICE.dbo.HUD_LINE hl827 on hl827.loanGeneral_Id = lg.loanGeneral_Id and hl827.hudType = 'HUD' and hl827._LineNumber = '827' and hl827.NetFeeIndicator = '1'
          where fd._FundedDate is not null and dl._CancelWithdrawnDate is null and
          lg.LenderRegistrationIdentifier = #{loan_num}

        eos
      )
      return result[0]['NetDeferral'] if result[0]
      nil
    end

    def has_mi?
      hud1003 = trid_loan? ? hud_lines.hud.where(system_fee_name: 'Mortgage Insurance').first : hud_lines.hud.where(line_num: 1003).first
      hud902  = trid_loan? ? hud_lines.hud.where(system_fee_name: 'Mortgage Insurance Premium').first : hud_lines.hud.where(line_num: 902).first

      if mortgage_type == 'Conventional'
        return true if (lender_paid_mi.present? && lender_paid_mi)
        return true if mi_certificate_id.present?
        return true if (hud1003.present? && hud1003.monthly_amount.present? && hud1003.monthly_amount.to_f > 0)
        return true if (payment_amount.present? && payment_amount != 0)
        return true if mi_program.present?
        return true if (mi_company_id.present? && mi_company_id != 0)
        return true if (hud902.present? && hud902.monthly_amount.present? && hud902.monthly_amount.to_f > 0)
        return false # default
      else
        return false
      end
    end

    def is_primary_residence_and_purchase?
      is_primary_residence? && purpose_type == 'Purchase'
    end

    def broker_replacement_comments
      lg = LoanGeneral.where(id: self.id).last
      if lg
        lg.loan_events.map{|e| e.event_description if e.event_description.starts_with?('Loan Transfer Completed')}.compact.join('; ')
      end
    end

    def is_purchase?
      purpose_type.to_s.downcase == 'purchase'
    end

    def is_refinance?
      purpose_type.to_s.downcase == 'refinance'
    end

    def internal_refinance?
      return false unless is_refinance? # its not internal if its not a refinance
      return false if (!liabilities || liabilities.size == 0)
      reo_ids = liabilities.first_lien.owned_by_ctm.map(&:reo_id).uniq.reject {|reo| reo.empty? }
      return false if reo_ids.size == 0
      reos    = reo_properties.where(reo_id: reo_ids, subject_indicator: 1)
      (reos && reos.size > 0) ? true : false
    end

    # if its a refinance, and its not an internal, then its true.
    def external_refinance?
      return false unless is_refinance?
      !internal_refinance?
    end

    # debt to income ratio
    def dti
      # per ctmweb-1943 adding this.
      #return 0 unless calculations.present?
      #calculations.select {|c| c.name == 'TotalObligationsIncomeRatio'}.first.value
      calculations.total_obligation_ratio
    end

    def escrow_coverage_amount
      hud = hud_lines.hud.where(line_num: 902).first
      hud.present? ? hud.total_amount : 0
    end

    # set this loan for custom boarding, outside of normal boarding criteria
    def set_for_boarding
      if !self.custom_loan_data.present?
        self.custom_loan_data = Master::LoanDetails::CustomLoanData.new({force_boarding: true}, without_protection: true)
      else
        self.custom_loan_data.force_boarding = true
      end
      self.custom_loan_data.save!
    end

    def applicant_wishes_to_apply?
      custom_fields.where(form_unique_name: "LO Certification", attribute_unique_name: "Apply").try(:last).try(:attribute_value)
    end

    def broker_requested_documents?
      initial_disclosure_requested_value == "Y"
    end

    def initial_disclosure_requested_value
      fields = if channel.in?(RETAIL_CHANNELS_WITH_TEST)
                  custom_fields.initial_disclosure_retail
               elsif channel.in?(WHOLESALE_CHANNELS_WITH_TEST)
                 custom_fields.initial_disclosure_wholesale
               else
                 []
               end

      return 'Y' if fields.any? { |f| f.attribute_value == 'Y'}
      return 'N' if fields.any? { |f| f.attribute_value == 'N'}
      nil   # ignore other values, such as "P"
    end

    def initial_disclosure_request_completed?
      initial_disclosure_request_completion_fields.any?
    end

    def initial_disclosure_requested_at
      disclosure_request_timestamp.try!(:disclosure_request_date)
    end

    def initial_disclosure_request_completion_fields
      thing = (channel == Channel.wholesale.identifier) ? "Wholesale" : "Retail"
      custom_fields.select do |cf|
        cf.form_unique_name == "#{thing} Initial Disclosure Request" &&
          cf.attribute_unique_name.gsub(' ', '') == "InternalUseOnly" &&
          !cf.attribute_value.blank? &&
          cf.attribute_value != "P"
      end
    end

    def docmagic_disclosure_request_created?
      loan_events.any?{ |e| e.event_description == "DocMagic Initial Disclosure Request" }
    end

    def trid_loan?
      return false if application_date.nil? 
      application_date >= TRID_DATE
    end

    def product_code_translated
      return product_code_uw if product_code_uw.present?
      return product_name if product_name.present?
      product_code
    end

    def property_state_translated
      return property_state_gfe if property_state_gfe.present?
      return property_state if property_state.present?
      property_state_lld
    end

    def is_locked?
      locked_at.present? && (lock_expiration_at.nil? || lock_expiration_at.beginning_of_day > Date.current)
    end

    def is_retail?
      Channel.retail_all_ids.include?(channel)
    end
  end

end
