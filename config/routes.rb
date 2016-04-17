CtmdbWeb::Application.routes.draw do

  # Unauthorized landing page CTMWEB-294
  get 'unauthorized' => 'unauthorized#index'

  # Changed per CTMWEB-254
  resources :portals
  root to: 'portals#index' #:to => redirect(portals_path)

  mount JobStatus::Engine => "/job_status"

  # Temp route for production launch
  get '/pre-closing' => 'underwriter/checklists#index'
  get '/pre-closing/underwriter/validations' => 'underwriter/validations#index'

  # Reporting or modelless routes
  get 'foo', :to => 'scratchpad#create'
  get '/last-trans', :to => 'service#last_transaction'

  # Navigation Update
  get '/update_navigation_contents/:navigation_name/:navigation_context', to: 'restricted_access#update_navigation_contents', as: 'update_menu'

  # Redirecting reports to new server path
  new_sql_server  =   Rails.env.production? ? 'otaaprodsql01' : 'otaadevsql01'
  new_reports_url =   "http://#{new_sql_server}/ReportServer/Pages/ReportViewer.aspx?"

  sql_server  =       Rails.env.production? ? 'otaaprodrps01' : 'otaadevrps01'
  reports_url =       "http://#{sql_server}/ReportServer/Pages/ReportViewer.aspx?"

  underwriting            = '%2fUnderwriting%2f'
  client_services         = '%2fClient+Services%2f'
  enterprise_compliance   = '%2fEnterprise+Compliance%2f'
  registration            = '%2fRegistration%2f'
  
  
  get "/reg_b_uw_submitted"                                           => redirect("#{new_reports_url}#{underwriting}UW_Submitted"),                            as: :reg_b_uw_submitted
  get "/reg_b_uw_received"                                            => redirect("#{new_reports_url}#{underwriting}UW_FileReceivedAssigned"),                 as: :reg_b_uw_received
  get "/reg_b_uw_pending_second_review"                               => redirect("#{new_reports_url}#{underwriting}UW_PendingSecondReview"),                  as: :reg_b_uw_pending_second_review
  get "/reg_b_uw_conditions_pending_review"                           => redirect("#{new_reports_url}#{underwriting}UW_FileReceivedNotAssigned"),              as: :reg_b_uw_conditions_pending_review
  get "/reg_b_uw_file_incomplete_conditions"                          => redirect("#{new_reports_url}#{underwriting}UW_FileIncomplete"),                       as: :reg_b_file_incomplete_conditions
  get "/reg_b_uw_waived_conditions"                                   => redirect("#{new_reports_url}#{underwriting}UW_WaivedConditions"),                     as: :reg_b_waived_conditions

  get "/ssrs_enterprise_compliance_flood_compliance_review"         => redirect("#{reports_url}#{enterprise_compliance}Flood+Compliance+Review"),              as: :ssrs_enterprise_compliance_flood_compliance_review
  
  get "/registration/reports/fcra_daily_report"                     => redirect("#{reports_url}#{registration}FCRA+Daily+Report"),                             as: :fcra_daily_report 

  get "/closing/reports/closing_checklist_report"                   => redirect("#{new_reports_url}%2fCTMReporting%2fClosing_ClosingCheckListReport"),                  as: :closing_checklist_report

  resources :checklist_mappings, only: :index
  resources :fact_types, only: :index do
    get 'search', on: :collection
  end

  namespace :qa do
    resources :loan_finder, only: [:index] do
      get 'search', on: :collection
    end
  end

  resources :florida_condo_pdfs, only: :index do
  end

  resources :manual_fact_types, only: [] do
    member do
      post :save
    end
  end

  resources :escrow_agents do
    collection do
      get 'agent_name'
      get 'agent_addr'
      get 'agent_city'
      get 'agent_state'
      get 'agent_zip'
    end
  end
  resources :decisionator_flows, only: :index do
    get 'validations', on: :collection
    get 'create_new_event', on: :collection
  end

  # Core resources
  namespace :core do
    resources :loans,         only: [:index, :show] do
      get 'search', on: :collection
    end
    resources :institutions,  only: [:index, :show] do
      get 'search', on: :collection
    end
    resources :originators,   only: [:index, :show] do
      get 'search', on: :collection
    end
  end

  # Administration
  namespace :admin do

    resources :navigations do
      as_routes
      get :autocomplete_role_name, :on => :member
    end

    resources :navigational_contexts do
      as_routes
    end

    resources :uwchecklist_sections do
      as_routes
    end

    resources :uwchecklist_items do
      as_routes
    end

    resources :usage_stats, only: :index do
      collection do
        get 'controllers'
        get 'actions'
        get 'users'
      end
    end

    resources :loan_validations, only: [:index, :create]

    resources :email_tests, only: [:index, :create]

  end

  resources :validation_alerts, only: [] do
    collection do
      post :reinstate
      post :clear
    end
  end

  resources :data_compare, only: [:show]

  # Funding team checklist
  
  namespace :funding do
    resources :validations, only: :index do
      collection do
        get 'search'
      end
    end

    resources :checklists, only: [:show, :update] do
      member do
        post :create
      end
    end

    resources :reports, only: [:index, :comparision] do
      collection do
        get 'report'
        get 'comparision'
      end
    end
  end

  #Initial Disclosure

  namespace :initial_disclosure do
    resources :work_queue, only: :index do
      member do
        post :assign_other
        post :assign_self
        post :save_status
        post :save_title_quote
      end
    end

    resources :validations, only: :index do
      collection do
        root 'validations#index'
        get 'search'
      end
    end
  end

  #ESign

  namespace :esign do
    resources :event_listings do
      collection do
        get 'index'
        get 'search'
      end
    end

    resources :borrower_work_queue do
      collection do
        get 'index'
      end
      put 'update', on: :member
    end

    resources :package_versions do
      collection do
        get 'most_recent_for_loan'
      end
    end

    resources :event_details do
      get 'show'
    end

    resources :documents do
      get 'show'
    end

  end

  #Registration

  namespace :registration do
    resources :validations do
      collection do
        get 'search'
        get 'process_flow'
      end
    end
    
    resources :checklists, only: [:show, :update] do
      member do
        post :create
      end
    end

    resources :esign_consent do
      collection do
        get 'index'
        get 'create'
        get 'search'
      end
    end

    resources :forced_registrations, only: [:index, :update]
    post 'forced_registrations' => 'forced_registrations#search', :as => 'forced_registrations_search'
  end

  #PreClosing

  namespace :preclosing do
    resources :validations, only: [:index, :show] do
      collection do
        get 'search'
        get 'process_flow'
      end
    end
  end

  namespace :underwriter do
    resources :validations, only: [:index, :show] do
      collection do
        get 'search'
        get 'process_flow'
        get 'process_validations'
        get 'determine_eligibility'
      end
    end
  end
  # Pre-Closing

  scope '/pre-closing' do
    namespace :uw_coordinator do
      resources :file_submitted_not_received, only: [:index, :update] do
        collection do
          get 'loan_counts'
        end

        member do
          get 'to_pdf'
          post 'assign_self'
        end
      end

      resources :cond_submitted_not_received, only: [:index]

      resources :pac_order_dates, only: :index

      resources :validations, only: [:index, :show] do
        collection do
          get 'search'
          get 'process_registration_validation_alert'
          get 'process_registration_validation_save'
        end
      end

      resources :arm_reports, only: :index
    end

    namespace :underwriter do
      resources :checklists, only: [:index, :show] do
        collection do
          get 'search'
        end
        member do
          get 'to_pdf'
        end
      end

      resources :file_received_no_uw_assigned, only: [:index] do
        collection do
          get 'count_by_received_date'
        end
      end
      resources :cond_pending_reviews, only: :index

      resources :product_data do
        as_routes
      end

      resources :product_guidelines do
        as_routes
      end

      resources :product_guideline_docs do
        as_routes
      end

      resources :admin_product_guidelines
    end

    namespace :uw_management do
      resources :files_to_be_underwritten, only: :index

      resources :pipeline_validations, only: :index
    end

    get 'uw_coordinator'  => 'menu_group#index'
    get 'underwriter'     => 'menu_group#index'
    get 'uw_management'   => 'menu_group#index'
    get 'closing_funding' => 'menu_group#index'
    get 'gfe_coordinator' => 'menu_group#index'

  end

  namespace :closing do
    resources :validations, only: [:search, :index] do
      collection do
        get 'search'
        get 'process_flow'
      end
      member do
        get 'set_cd_only'
      end
    end
    resources :closing_request_ready_for_docs, only: :index do
      collection do
        get 'channel_counts'
      end
    end
    resources :checklists, only: [:show, :update] do
      member do
        post :create
      end
    end
    resources :checklist_experiments, only: [:index] do
    end
    resources :loan_modelers, only: [:index, :show] do
      collection do
        get 'search'
        post 'submit'
        post 'dodd_frank_misc_fee_remove'
        post 'fund_submit'
        post 'fredd_submit'
        post 'broker_submit'
      end
    end
    
    resources :loan_modeler_pre_trids, only: [:index, :show] do
      collection do
        get 'search'
        post 'submit'
        post 'dodd_frank_misc_fee_remove'
        post 'fund_submit'
        post 'fredd_submit'
        post 'broker_submit'
      end
    end

    resources :closing_requests_awaiting_reviews, only: :index do
      collection do
        get 'channel_counts'
      end
      member do
        get 'to_pdf'
      end
    end

    resources :closing_request_receiveds, only: :index do
      collection do
        get 'filter_by_date'
      end
    end

    resources :scheduled_fundings, only: :index do
      collection do
        get 'filter_by_date'
      end
    end

    resources :pending_funding_requests, only: :index

    resources :loan_notes, only: [:index, :edit, :new]

    resources :settlement_agent_audits do
      collection do
        get 'last_audit'
        post 'create_audit'
        get 'reports'
        get 'is_closing_lead'
        get 'comparision_report'
      end
    end
  end

  namespace :accounting do

    # START branch_compensations routes
    resources :branch_commission_reports

    resources :branch_compensations

    resources :branch_compensation_details

    resources :branch_employee_other_compensations

    resources :datamart_user_compensation_plans

    resources :commission_plan_details, only: [:index]

    resources :datamart_user_profiles
    # END branch_compensations routes

    resources :scheduled_fundings do
      as_routes
    end
    resources :regions do
      as_routes
    end
    resources :area_manager_regions do
      as_routes
    end
    resources :branches do
      as_routes
    end
    resources :branch_employees do
      as_routes
    end
    resources :sales_kpi_report_files do
      as_routes
    end

  end

  # Post-Closing
  scope '/post-closing/funding' do
    namespace :hmda do
      namespace :reporting do
        resources :investor_reports
      end
    end
  end

  namespace :bpm do
    resources :statistic_reports do
      collection do
        get 'underwriters'
        get 'validation_errors'
        get 'mark_as_reviewed'
        get 'prior_searches'
      end
      member do
        get 'export'
      end
    end

    resources :validation_reports do
      as_routes
    end
  end



  # Delivery
  namespace :delivery do

    resources :redwood_loans, :only => [:index] do
      collection do
        get 'export'
      end
    end

    resources :fnma_pools_v2, :only => [] do
      collection do
        get 'export'
        get "loan_test"
      end
    end

    resources :fnma_loans, :only => [:index] do
      collection do
        get 'export'
        get 'bony_mellon_export'
        get 'filter_by_date'
        get "loan_test"
      end
      member do
        get "loan_balance_details"
      end
    end

    resources :fhlb_pools, :only => [:index] do
      collection do
        get 'export'
        get 'export_fhlb_csv'
        get 'filter_by_date'
        get "loan_test"
        get "export_pre_uldd"
        get "export_pre_csv"
      end
      member do
        get "loan_balance_details"
      end
    end

    resources :gnma_loans, :only => [:index] do
      collection do
        get 'export'
        get 'bony_mellon_export'
        get 'filter_by_date'
      end
      member do
        get "loan_balance_details"
      end
    end

    resources :fnma_cash, :only => [:index] do
      collection do
        get 'export'
        get 'bony_mellon_export'
        get 'filter_by_date'
      end
      member do
        get "loan_balance_details"
      end
    end

    resources :fhlmc_cash, :only => [:index] do
      collection do
        get 'export'
        get 'bony_mellon_export'
        get 'filter_by_date'
      end
      member do
        get "loan_balance_details"
      end
    end

    resources :fhlmc_pools, :only => [:index] do
      collection do
        get 'export'
        get 'bony_mellon_export'
        get 'filter_by_date'
      end
      member do
        get "loan_balance_details"
      end
    end

    resources :fhlmc_individuals, only: [:index] do
      collection do
        get 'export'
        get 'filter_by_loan'
      end
      member do
        get "loan_balance_details"
      end
    end

    resources :fhlmc_loans, :controller => 'fhlmc_individuals' do
      collection do
        get 'loan_test'
      end
    end
  end

  # Compliance
  namespace :compliance do
    namespace :rego do
      resources :rego_reports do
        as_routes
      end
      resources :ctm_execs do
        as_routes
      end
    end

    namespace :hmda do

      resources :data_change_reports, only: [:index] do
        collection do
          get :search
        end
      end

      resources :quarterly_annuals do
        collection do
          get :search
          get :transform
        end
      end

      resources :loan_compliance_events, only: [:index, :update, :edit] do
        collection do
          post :index
          get :import_form
          get :import
          post :import
          get :export_form
          get :export
          get :undo_export_form
          post :undo_export
          get :transform
          get :update_form
          post :mass_update
          get :set_session
        end
      end

      resources :purchased_loans, only: [:index] do
        collection do
          get :import_form
          get :import
          post :import
          get :search
        end
      end

      resources :loan_compliance_exceptions do
        collection do
          get :search
          get :reconcile
        end
      end

      resources :loan_compliance_exception_reports do
        as_routes
        collection do
          get :build_report
        end
      end

      resources :loan_compliance_non_reportables, only: [:index] do
        collection do
          get :search
        end
      end

      resources :loan_compliance_filters, only: [:index] do
        collection do
          get 'bulk_update'
          post 'remove_event'
        end
      end

      resources :hmda_investor_codes do
        collection do
          get 'update_investor'
        end
      end
    end
  end

  resources :loan_compliance_events, only: [:update]

  namespace :servicing do
    resources :manual_boarding do
      collection do
        post 'find_loans'
        get 'board'
      end
    end
    resources :boarding_files do
      as_routes
      collection do
        get :download_url
        get :test_one_loan
        get :test_loans
      end
      member do
        get :show
      end
    end
  end

  resources :loan_notes do
    as_routes
  end

  resources :uw_submit_date_exceptions, only: [:index]

  resources :credit_suisse_ops_reports do
    as_routes
  end
  resources :investor_pricing_imports, only: [:index, :new, :create]

  resources :credit_suisse_lock_exports, only: [:index, :show] do
    collection do
      get 'search'
      get 'export'
    end
  end

  resources :credit_suisse_appraisal_exports, only: [:index, :show] do
    collection do
      get 'search'
      get 'export'
    end
  end

  resources :credit_suisse_funding_exports, only: [:index, :show] do
    collection do
      get 'search'
      get 'export'
    end
  end

  resources :credit_suisse_post_closing_exports, only: [:index, :show] do
    collection do
      get 'search'
      get 'export'
    end
  end

  # General resources
  resources :notes do
    as_routes
  end

  resources :allonge do
    collection do
      get :allonges
    end
  end

  resources :accounting_reports, only: [] do
    collection do
      get :download_url
    end
  end

  resources :edit_notes, only: [:getnote, :editnote, :can_edit] do
    collection do
      get :getnote
      post :editnote
      get :can_edit
    end
  end

  namespace :smds do
    resources :dmi_trial_bal_by_investors, only: [:index, :new, :create] do
      collection do
        post :import
        get  :preview
      end
    end
    resources :pools, only: :update
    resources :gnma_pools, only: :update
    resources :cash_commitments, only: :update
  end

  resources :state_title_vendors do
    as_routes
  end

  resources :vendors do
    as_routes
  end

  # CAS
  controller :session do
    get 'logout' => :destroy
  end

  resources :error_test, only: [:index]
  # Development scratchpad - this exists solely as a place to try out functionality
  # during development without touching the main features/functions

  namespace :dev do
    resources :scratchpads

  end

  if Rails.env.test?
    resources :anonymous
  end

  require 'delayed_job_web'
  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]

end
