# class Accounting::BranchesController < RestrictedAccessController

#   load_and_authorize_resource class: Institution


#   active_scaffold :institution do |config|
#     config.columns = [:branch_name, :employees, :branch_compensations]
#     config.label = 'Branch Compensation Plans'
#     config.list.sorting = { branch_name: :asc }

#     # config.nested.add_link :branch_compensations, label: 'Compensation Plans'
#     config.columns[:branch_name].sort_by :method => 'branch_name'
#     config.list.per_page = 100

#     config.actions.exclude :show
#     config.actions.exclude :delete
#     config.actions.exclude :create
#     config.actions.exclude :update
#     config.actions.exclude :search

# #:create, :list, :search, :show, :update, :delete, :nested, :subform

#   end

#   def beginning_of_chain
#     #only want to see Affiliate Standard branches
#     super.affiliate
#   end

#   # def list_authorized?
#   #   @current_user.in_protected_group?
#   # end

# end
