module Decisions
  class Flow
    attr_reader :flow_name, :flow_rule_id, :fact_types
    attr_accessor :response, :result
    
    # validate entry for each flow is used to run the validations in the daily run job. Specify the validation type in which it will be triggered.
    # If validate: "underwriter", then the flow will be executed in underwriter, preclosing and closing. This is calculated in Decisions::validator for daily run job.
    
    FLOWS = {:asset_acceptance     => {name: 'Assets Acceptance', rule_id: 64 , validate: "underwriter", except: []},
             :aus                  => {name: 'AUS Acceptance', rule_id: 69,  validate: "underwriter", except: []},
             :dti                  => {name: 'DTI Acceptance', rule_id: 63, validate: "underwriter", except: []},
             :hpml_compliance      => {name: 'HPML Compliance', rule_id: 65,  validate: "underwriter", except: []},
             :product_eligibility  => {name: 'Product Eligibility', rule_id: 1025, validate: "underwriter", except: []},
             :ausreg               => {name: 'AUS Registration Acceptance', rule_id: 66, validate: "registration", except: ['underwriter','preclosing','closing']},
             
             :documents_expiration_dates_acceptance   => {name: 'Documents Expiration Dates Acceptance', rule_id: 67, validate: "underwriter", except: []},
             
             :preclosing               => {name: 'PreClosing Acceptance', rule_id: 68, validate: "preclosing", except: []},
             :florida_condo_acceptance => {name: 'Florida Condo Acceptance', rule_id: 70, validate: "underwriter", except: []},
             :project_classification_1008_acceptance  => {name: 'Project Classification 1008 Acceptance', rule_id: 71, validate: "underwriter", except: []},
             :ratio_change_acceptance  => {name: 'Ratio Change Acceptance', rule_id: 72, validate: "closing", except: []},
             :escrow_waiver_acceptance => {name: 'Escrow Acceptance', rule_id: 73, validate: "underwriter", except: []},
             # :registration_acceptance  => {name: 'Registration Acceptance', rule_id: 74, validate: ["registration"]},
             
             :arm_gfe_acceptance       => {name: 'ARM GFE Acceptance', rule_id: 75, validate: "initial_disclosure", except: []},
             :arm_rate_lock_acceptance => {name: 'ARM Rate Lock Acceptance', rule_id: 76, validate: "initial_disclosure", except: []},
             :arm_1003_acceptance      => {name: 'ARM 1003 Acceptance', rule_id: 77, validate: "initial_disclosure", except: []},
             :rate_lock_expiration_dates => {name: 'Rate Lock Expiration Date', rule_id: 79, validate: "preclosing", except: []},
             :credit_score_comparison_acceptance => {name: 'Credit Score Comparison Acceptance', rule_id: 81, validate: "underwriter", except: []},
             
             :compensation_acceptance  => {name: 'Compensation Acceptance', rule_id: 82, validate: "initial_disclosure", except: ['registration', 'underwriter','preclosing','closing']},
             :appraisal_acceptance     => {name: 'Appraisal Acceptance', rule_id: 83, validate: "underwriter", except: []}, 
             # :preapproval_acceptance   => {name: 'PreApproval Acceptance', rule_id: 84, validate: ["initial_disclosure", "registration", "underwriter", "preclosing", "closing"]},
             # :closing_cost_exp_date    => {name: 'Closing Cost Exp Date', rule_id: 85, validate: ["initial_disclosure", "registration", "underwriter", "preclosing", "closing"]},
             
             :le_box_b                 => {name: 'LE Box B', rule_id: 86, validate: "initial_disclosure", except: ['registration', 'underwriter','preclosing','closing']},
             :le_box_c                 => {name: 'LE Box C', rule_id: 88, validate: "initial_disclosure", except: ['registration', 'underwriter','preclosing','closing']},
             :le_box_e_acceptance      => {name: 'LE Box E Acceptance', rule_id: 89, validate: "initial_disclosure", except: ['registration', 'underwriter','preclosing','closing']},
             :le_box_g                 => {name: 'LE Box G', rule_id: 90, validate: "initial_disclosure", except: ['registration', 'underwriter','preclosing','closing']},
             :determine_cd_recipients  => {name: 'CD Recipients', rule_id: 91, validate: "preclosing", except: []},
             
             :other_data_1003          => {name: 'Other Data 1003', rule_id: 92, validate: "underwriter", except: []},
             :va_funding_fee_amt       => {name: 'WEB VA Percentage', rule_id: 93, validate: "initial_disclosure", except: []},
             :minimum_closing_date     => {name: 'Minimum Closing Date', rule_id: 94, validate: "preclosing", except: []},
             :maximum_closing_date     => {name: 'Maximum Closing Date', rule_id: 95, validate: "preclosing", except: []},
             :mb_closing_date_waiting_period  => {name: 'MB Closing Date Waiting Period', rule_id: 96, validate: "none", except: []},
             # :closing_fee_tolerance    => {name: "Closing Fee Tolerance", rule_id: 97, validate: ["preclosing", "closing"]},
             
             :insurance_documents_acceptance  => {name: "Insurance Documents Acceptance", rule_id: 98, validate: "preclosing", except: []},
             :disclosure_method        => {name: "Disclosure Method", rule_id: 99, validate: "initial_disclosure", except: []},
             :intent_to_proceed        => {name: "Intent to Proceed", rule_id: 100, validate: "registration", except: ['underwriter','preclosing','closing']},
             :le_page_three            => {name: "LE Page Three", rule_id: 101, validate: "initial_disclosure", except: ['registration', 'underwriter','preclosing','closing']},
             :application_date_compliance => {name: "Application Date Compliance", rule_id: 102, validate: "initial_disclosure", except: ['registration', 'underwriter','preclosing','closing']},
             :closing_verification_date_acceptance => {name: "Closing Verification Date Acceptance", rule_id: 103, validate: "preclosing", except: []},
             
             :closing_date             => {name: "Closing Date", rule_id: 104, validate: "preclosing", except: []},
             :le_box_a                 => {name: "LE Box A", rule_id: 105, validate: "initial_disclosure", except: ['registration', 'underwriter','preclosing','closing']},
             # 106 is for underwriter validations ruby rules
             # 107 is for data compare
             :mortgage_insurance       => {name: "Mortgage Insurance Acceptance", rule_id: 108, validate: "initial_disclosure", except: []},
             :government_monitoring_acceptance  => { name: "Government Monitoring Acceptance", rule_id: 109, validate: "none", except: [] },
             :tbd_policy_acceptance    => { name: "TBD Policy Acceptance", rule_id: 110, validate: "registration", except: ['underwriter', 'preclosing', 'closing']},
             :le_box_j_acceptance      => { name: "LE Box J Acceptance", rule_id: 111, validate: "initial_disclosure", except: ['registration', 'underwriter', 'preclosing', 'closing'] },
             :texas_50a6_acceptance    => { name: "Texas 50A6 Acceptance", rule_id: 112, validate: "underwriter", except: []},
             # :max_cash_back_acceptance => { name: "Max Cash Back Acceptance", rule_id: 113, validate: "underwriter", except: []},
             :general_eligibility      => { name: "General Eligibility", rule_id: 114, validate: "underwriter", except: [] },
            }

    # Use 87 as the rule_id for warnings issued from the registration checklist, 
    # which is not a flow but still issues warnings.  
    REGISTRATION_CHECKLIST_RULE_ID = 87

    UNDERWRITER_VALIDATION_RULE_ID = 106
    DATA_COMPARE_RULE_ID = 107

    def initialize(flow_name, fact_types)
      @fact_types   = fact_types
      @flow_name    = FLOWS[flow_name.to_sym][:name]
      @flow_rule_id = FLOWS[flow_name.to_sym][:rule_id]
      @response     = nil
      @result       = {:errors => [], :warnings => [], :raw_response => nil, :conclusion => nil}
    end

    def execute
      call_decisionator
      extract_raw_response
      extract_conclusion
      extract_warning_messages
      extract_error_messages

      result
    end

    def call_decisionator
      @response = Ctmdecisionator::Flow.execute(flow_name, @fact_types)
    end

    def extract_raw_response
      result[:raw_response] = @response
    end

    def extract_conclusion
      result[:conclusion] = @response[:conclusion]
    end

    def extract_error_messages
      result[:errors] = transform_messages response[:stop_messages]
    end
    
    def extract_warning_messages
      return unless flow_rule_id
      result[:warnings] = transform_messages response[:warning_messages]
    end

    private 

    def transform_messages messages
      Array(messages).compact.map do |text|
        { rule_id: flow_rule_id, text: text }
      end
    end
  end
end

