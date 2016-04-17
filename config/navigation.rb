# case request.subdomain
# when 'ops'

#   SimpleNavigation::Configuration.run do |navigation|
#     navigation.selected_class = 'active'
#     navigation.active_leaf_class = 'active-leaf'

#     navigation.items do |level_one|

#       level_one.item(:pre_closing, 'Pre-Closing', underwriter_checklists_path, :class => 'menu', :link => {:class => '', :title => 'Pre Closing Popup'}, :if => Proc.new{user_is_permitted? :pre_closing}) do |level_two|

#         level_two.item :uw_coordinator,   'UW Coordinator',   "#" do |level_three|
#           #, :if => Proc.new{user_is_permitted? :uw_coordinator}
#           level_three.item :file_submitted_not_received, 'File Submitted, Not Received', uw_coordinator_file_submitted_not_received_index_path
#           #level_three.item :files_to_be_underwritten,   'Files to be Underwritten',  uw_management_files_to_be_underwritten_index_path
#           level_three.item :cond_submitted_not_received,   'Conditions Submitted, Not Received',  uw_coordinator_cond_submitted_not_received_index_path
#         end # uw_coordinator




#         level_two.item :underwriter, 'Underwriter', '#' do |level_three|
#           level_three.item :uw_checklist,   'Checklist',  underwriter_checklists_path
#           level_three.item :file_rec_no_uw, 'File Recv\'d, No UW',         underwriter_file_received_no_uw_assigned_index_path
#           level_three.item :file_rec_no_uw, 'Conditions Pending Review',   underwriter_cond_pending_reviews_path
#           if @current_user.is_underwriter? || @current_user.is_underwriter_with_employee_loan_permission? || @current_user.is_admin?
#             level_three.item :uw_validation, 'Validation / Final Approval',   underwriter_validations_path
#             # level_three.item :uw_admin_product_guidelines, 'UW Admin',   underwriter_admin_product_guidelines_path
#           end
#         end # underwriter



#         level_two.item :uw_management,   'UW Management',   "#" do |level_three|
#           #, :if => Proc.new{user_is_permitted? :uw_coordinator}
#           level_three.item :files_to_be_underwritten,   'Files to be Underwritten',  uw_management_files_to_be_underwritten_index_path
#           #level_three.item :pipeline_validation, 'Pipeline Validation Report', uw_management_pipeline_validations_path
#         end # uw_management

#       end # Pre-closing

#       level_one.item :closing, 'Closing/Funding', closing_closing_requests_awaiting_reviews_path do |level_two|
#         level_two.item :closing_requests_awaiting_review, 'Closing Requests Awaiting Review', closing_closing_requests_awaiting_reviews_path
#         level_two.item :closing_request_ready_for_doc, 'Closing Requests Ready for Docs', closing_closing_request_ready_for_docs_path
#         level_two.item :scheduled_funding, 'Fundings Scheduled', closing_scheduled_fundings_path
#         level_two.item :closing_request_received, 'Closing Requests Received', closing_closing_request_receiveds_path
#         level_two.item :pending_funding_request, 'Funding Requests Pending', closing_pending_funding_requests_path
#         level_two.item :checklists, 'Closing Checklist', closing_checklists_path
#       end


#       #level_one.item :post_closing, 'Post-Closing', hmda_reporting_investor_reports_path do |level_two|
#       #  level_two.item :hmda,   'HMDA',   "#" do |level_three|
#       #    level_three.item :hmda_reporting_investor_reports, 'Investor Report', hmda_reporting_investor_reports_path
#       #  end # hmda
#           #end # compliance

    
#       # Show if they are in Sales / Admin
#       if @current_user.is_sales? || @current_user.is_admin?
#         level_one.item :sales, 'Sales', '#' do |level_two|
#           level_two.item :sales_reporting, 'Reports', '#' do |level_three|
#             level_three.item :sales_loan_daily_pipeline_reports, 'Funded by Branch', accounting_loan_daily_pipeline_reports_path
#           end 
#           level_two.item :regions, 'Regions', accounting_regions_path
#         end
#       end

#       # hr should be able to edit/create plans
#       if @current_user.is_human_resources?
#         level_one.item :human_resources, "Human Resources", '#' do |level_two|
#           level_two.item :accounting_commission_plan_details, 'Commission Plan Details', accounting_commission_plan_details_path
#           level_two.item :accounting_branches, 'Branch Compensations', '#' do |level_three|
#             level_three.item :accounting_branches, 'Branches', accounting_branches_path
#             level_three.item :accounting_loan_officers, 'Loan Officers', accounting_loan_officers_path
#           end
#         end
#       end

#      # # accounting should be able to view 
#       if @current_user.is_accounting?
#         level_one.item :accounting, "Accounting", accounting_scheduled_fundings_path do |level_two|
#           level_two.item :accounting_reports, 'Reporting', '#' do |level_three|
#             level_three.item :accounting_branch_commission_reports, 'Branch Commissions', accounting_branch_commission_reports_path
#             level_three.item :accounting_commission_plan_details, 'Commission Plan Details', accounting_commission_plan_details_path
#           end
#           # read
#         level_two.item :accounting_branches, 'Branch Compensations', '#' do |level_three|
#             level_three.item :accounting_branches, 'Branches', accounting_branches_path
#             level_three.item :accounting_loan_officers, 'Loan Officers', accounting_loan_officers_path
#           end
#         end
#       end



#       #level_one.item :delivery, 'Delivery', delivery_redwood_exports_path do |level_two|
#       #  level_two.item :redwood, 'Redwood Export', delivery_redwood_exports_path
#       #end # Delivery


#       level_one.item :nmls, 'NMLS', nmls_path do |level_two|
#         level_two.item :nmls_originators, 'Originators', originators_nmls_path
#         level_two.item :nmls_institutions, 'Institutions', institutions_nmls_path
#         level_two.item :nmls_validations, 'Loan Validation' , validations_nmls_path
#       end



#   #    # , :if => Proc.new{current_user.role_symbols.include?(:super_admin)}
#   #    level_one.item :admin, 'Admin', admin_users_path do |level_two|
#   #
#   #      level_two.item :delayed_job_workers, 'Job Queue', delayed_job_admin_path
#   #
#   #      # level_two.dom_class = 'dropdown-menu'
#   #      level_two.item :accounts,        'Accounts',       admin_accounts_path
#   #      level_two.item :users,           'Users',          admin_users_path
#   #
#   #      #level_two.item :divider,'','',:class => 'divider'
#   #
#   #      level_two.item :companies,       'Companies',      admin_companies_path
#   #      level_two.item :departments,     'Departments',    admin_departments_path
#   #      level_two.item :job_titles,      'Job Titles',     admin_job_titles_path
#   #
#   #      #level_two.item :divider,'','',:class => 'divider'
#   #
#   #      level_two.item :functions,       'Functions',      admin_functions_path
#   #      level_two.item :roles,           'Roles',          admin_roles_path
#   #      level_two.item :groups,          'Groups',         admin_groups_path
#   #      level_two.item :permissions,     'Permissions',    admin_permissions_path
#   #
#   #      level_two.item :divider,'','',:class => 'divider'
#   #
#   #      #level_two.item :uw_checklists,   'Underwriter Checklist',    admin_uwchecklist_sections_path
#   #
#   #    end

#     end # level_one

#   end # navigation

# else
  
#   SimpleNavigation::Configuration.run do |navigation|
#     navigation.selected_class = 'active'
#     navigation.active_leaf_class = 'active-leaf'

#     navigation.items do |level_one|
#       level_one.item :compliance, 'Compliance', compliance_mers_reconciliation_reports_path do |level_two|
#         level_two.item :mers_reporting, 'MERS', '#' do |level_three|
#           level_three.item :mers_reconciliation_reports, 'Reconciliation', compliance_mers_reconciliation_reports_path
#           level_three.item :mers_biennial_reviews, 'Biennial Reviews', compliance_mers_biennial_reviews_path
#           # level_three.item :mers_exceptions, 'Exceptions',  compliance_mers_mers_exceptions_path
#           level_three.item :mers_imports, 'MERS Imports', compliance_mers_mers_imports_path
#           # level_three.item :mers_loans,   'MERS Loans', compliance_mers_mers_loans_path
#           level_three.item :dmi_imports,  'DMI Imports',  compliance_mers_dmi_imports_path
#           # level_three.item :dmi_loans,    'DMI Loans',  compliance_mers_dmi_loans_path
#           level_three.item :mers_orgs,    'MERS Organizations',  compliance_mers_mers_orgs_path
#         end #mers_reporting
#       end # compliance
#     end
#   end
# end













# # level_two.item :uw_management,   'UW Management',     uw_management_path
# #       level_two.item :closing_funding, 'Closing/Funding',   closing_funding_path
# #       level_two.item :uw_management,   'GFE Coordinator',   gfe_coordinator_path

# # level_one.item(:post_closing, 'Post Closing', '/post-closing_funding', :class => 'menu', :link => {:class => 'menu', :title => 'Post Closing Popup'}, :if => Proc.new{user_is_permitted? :post_closing}) do |level_two|
# #   # level_two.dom_class = 'dropdown-menu'
# # end
# #
# # level_one.item(:level_two, 'level_two', '/level_two', :class => 'menu', :link => {:class => 'menu', :title => 'level_two Market Support'}, :if => Proc.new{user_is_permitted? :level_two}) do |level_two|
# #   # level_two.dom_class = 'dropdown-menu'
# # end
# #
# # level_one.item(:servicing, 'Servicing', '/servicing', :class => 'menu', :link => {:class => 'menu', :title => 'Post Closing Popup'}, :if => Proc.new{user_is_permitted? :servicing}) do |level_two|
# #   # level_two.dom_class = 'dropdown-menu'
# # end



