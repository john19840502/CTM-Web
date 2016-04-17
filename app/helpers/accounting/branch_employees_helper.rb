module Accounting::BranchEmployeesHelper

  # def branch_compensations_form_column(record, options)
  #   select :record, :branch_compensations, BranchCompensation.where(institution_id: record.institution_id).collect {|p| [ p.name, p.id ] }
  # end

  # def plan_date_column(record, column)
  #   I18n.localize(record.branch_compensations[0].current_package.effective_date, :format => :pretty) rescue nil
  # end

  # # update the ultipro employee id # for this user
  # def ultipro_emp_id_column(record, column)
  #   # if @current_user.is_human_resources? # they can edit
  #     best_in_place record, :ultipro_emp_id, type: :input, path: "/accounting/branch_employees/#{record.id}"
  #   # elsif @current_user.is_accounting?
  #   #   record.ultipro_emp_id
  #   # else
  #   #   "-"
  #   # end
  # end

  # def branch_name_column(record, column)
  #   # Do not allow Edit in Place if cannot manage.
  #    # if @current_user.is_human_resources?
  #      best_in_place record, :branch_id, type: :select, collection: Institution.affiliate.map {|br| [br.id, br.branch_name]}.insert(0, ["", "None"]), path: "/accounting/branch_employees/#{record.id}"
  #    # else
  #    #   record.branch_name
  #    # end
  # end

  # def profile_title_column(record, column)
  #   # Do not allow Edit in Place if cannot manage.
  #   # if @current_user.is_human_resources?
  #     best_in_place record, :profile_title, type: :select, collection: UserProfile::ACCOUNTING_TITLES.map {|at| [at, at]}.insert(0, ["", "None"]), path: "/accounting/branch_employees/#{record.id}"
  #   # else
  #   #   record.profile_title
  #   # end
  # end

  # def preferred_first_name_column(record, column)
  #   # Do not allow Edit in Place if cannot manage.
  #   # if @current_user.is_human_resources?
  #     best_in_place record, :preferred_first_name, path: "/accounting/branch_employees/#{record.id}"
  #   # else
  #   #   record.preferred_first_name
  #   # end
  # end

  # def branch_compensations_column(record, column)
  #   record.current_compensation_name
  # end

  # def lo_traditional_split_column(record, column)
  #   number_to_percentage(current_package(record).lo_traditional_split, precision: 2) rescue nil
  # end

  # def tiered_split_low_column(record, column)
  #   number_to_percentage(current_package(record).tiered_split_low, precision: 2) rescue nil
  # end

  # def tiered_split_high_column(record, column)
  #   number_to_percentage(current_package(record).tiered_split_high, precision: 2) rescue nil
  # end

  # def tiered_amount_column(record, column)
  #   number_to_currency(current_package(record).tiered_amount, precision: 0) rescue nil
  # end

  # def current_package(record)
  #   record.current_commission_details.branch_compensation.current_package
  # end

end
