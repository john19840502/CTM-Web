module Accounting::CommissionPlanDetailsHelper
  
  def profile_cells emp, for_xls = false
    start_tag = get_start_tag for_xls
    end_tag = get_end_tag for_xls

    profile = emp.current_profile_for_branch(emp["branch_id"])
    if can? :read, CommissionPlanDetail
      if profile.try(:ultipro_emp_id).present?
        ultipro_id = profile.ultipro_emp_id
      else
        profile_with_ultipro = DatamartUserProfile.where{ (datamart_user_id == emp.id) & (ultipro_emp_id.not_eq nil) }.last
        ultipro_id = profile_with_ultipro.ultipro_emp_id if profile_with_ultipro.present?
      end
    else
      ultipro_id = ''
    end

    html = ''

    if profile
      html << "#{start_tag}#{ultipro_id}#{end_tag}"
      html << "#{start_tag}#{profile.title}#{end_tag}"
      html << "#{start_tag}#{profile.preferred_first_name}#{end_tag}"
    elsif ultipro_id.present?
      html << "#{start_tag}#{ultipro_id}#{end_tag}"
      2.times { html << "#{start_tag}#{end_tag}" }
    else
      3.times { html << "#{start_tag}#{end_tag}" }
    end
    html
  end

  def comp_plan_cells emp, for_xls = false
    start_tag = get_start_tag for_xls
    end_tag = get_end_tag for_xls

    plan = emp.current_compensation_details_for_branch(emp["branch_id"])
    html = ''

    if plan
      html << "#{start_tag}#{number_to_percentage plan.lo_traditional_split, precision: 3}#{end_tag}"
      html << "#{start_tag}#{number_to_percentage plan.tiered_split_low, precision: 3}#{end_tag}"
      html << "#{start_tag}#{number_to_percentage plan.tiered_split_high, precision: 3}#{end_tag}"
      html << "#{start_tag}#{number_to_currency plan.tiered_amount, precision: 0}#{end_tag}"
      html << "#{start_tag}#{number_to_currency plan.lo_min, precision: 0}#{end_tag}"
      html << "#{start_tag}#{number_to_currency plan.lo_max, precision: 0}#{end_tag}"
    else
      6.times { html << "#{start_tag}#{end_tag}" }
    end
    html
  end
  
  def non_plan_comp_cells emp, for_xls = false
    start_tag = get_start_tag for_xls
    end_tag = get_end_tag for_xls

    non_plan = emp.current_non_plan_comps_for_branch(emp["branch_id"])
    html = ''

    if non_plan
      html << "#{start_tag}#{number_to_currency non_plan.per_loan_processed, precision: 2}#{end_tag}"
      html << "#{start_tag}#{number_to_currency non_plan.per_loan_branch_processed, precision: 2}#{end_tag}"
      html << "#{start_tag}#{number_to_percentage non_plan.bsm_override, precision: 3}#{end_tag}"
      html << "#{start_tag}#{number_to_percentage non_plan.bmsf_override, precision: 3}#{end_tag}"
    else
      4.times { html << "#{start_tag}#{end_tag}" }
    end
    html
  end

  def get_start_tag for_xls
    if for_xls
      "<Cell><Data ss:Type='String'>"
    else
      "<td>"
    end
  end

  def get_end_tag for_xls
    if for_xls
      "</Data></Cell>"
    else
      "</td>"
    end
  end

end