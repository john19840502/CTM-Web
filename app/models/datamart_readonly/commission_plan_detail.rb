class CommissionPlanDetail < BranchEmployee
  include ActionView::Helpers

  def location
    "#{city}, #{state}"
  end

  # db has some names like "John Paul" as first name.
  def fixed_first_name
    first_name.split(" ")[0]
  end

  def termination_date
    if self.datamart_user_compensation_plans.first.blank?
      nil
    else
      self.datamart_user_compensation_plans.first.termination_date 
    end
  end

  def preferred_first_name bid
    current_profile_for_branch(bid).try(:preferred_first_name)
  end

  def branch_name bid
    branches.where(id: bid).last.try(:branch_name)
  end

  def profile_title bid
    current_profile_for_branch(bid).try(:title)
  end

  def ultipro_emp_id bid
    current_profile_for_branch(bid).try(:ultipro_emp_id)
  end

  def lo_min
    lo_min = current_compensation_details.lo_min rescue nil
    number_to_currency(lo_min)
  end

  def lo_max
    lo_max = current_compensation_details.lo_max rescue nil
    number_to_currency(lo_max)
  end

  def commission_plan_date
    current_package.blank? ? "" : current_package.effective_date.strftime('%B %d, %Y')
  end

  def traditional_split
    current_package.blank? ? "" : number_to_percentage(current_package.lo_traditional_split, :precision => 3)
  end

  def tiered_split_low
    current_package.blank? ? "" : number_to_percentage(current_package.tiered_split_low, :precision => 3)
  end

  def tiered_split_high
    current_package.blank? ? "" : number_to_percentage(current_package.tiered_split_high, :precision => 3)
  end

  def tiered_amount
    current_package.blank? ? "" : number_to_currency(current_package.tiered_amount)
  end

  def amount_per_loan
    current_compensation_details.blank? ? "" : number_to_currency(current_compensation_details.per_loan_processed)
  end

  def amount_per_branch
    current_compensation_details.blank? ? "" : number_to_currency(current_compensation_details.per_loan_branch_processed)
  end

  def bsm_override
    current_compensation_details.blank? ? "" : number_to_percentage(current_compensation_details.bsm_override, :precision => 3)
  end

  private 

  def current_package
    return nil if (current_compensation_details.nil? or current_compensation_details.branch_compensation.nil?)
    current_compensation_details.branch_compensation.current_package
  end

  def current_package_branch_id
    return nil if (current_compensation_details.nil? or current_compensation_details.branch_compensation.nil?)
    current_compensation_details.branch_compensation.institution_id
  end

  def current_package_user_profile
    current_profile_for_branch current_package_branch_id
  end
end
