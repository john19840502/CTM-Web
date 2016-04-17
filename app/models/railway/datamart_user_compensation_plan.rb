class DatamartUserCompensationPlan < DatabaseRailway
  belongs_to :datamart_user
  belongs_to :employee, class_name: 'BranchEmployee', foreign_key: :datamart_user_id
  belongs_to :branch_compensation

  validates :datamart_user_id, :branch_compensation_id, :effective_date, presence: true
  validates :effective_date, allow_nil: true, allow_blank: true, timeliness: { on_or_after: lambda { (Date.today - 365.days) } }

  validate :effective_date_uniqueness
  validate :effective_date_is_after_plan_effective_date, if: :effective_date
  validate :plan_must_have_details, if: :effective_date
  validate :must_not_reselect_current_plan, if: :branch_compensation_id

  def termination_date
    branch_compensation.termination_date
  end

  # get branch_compensation_details < end_of_day.last
  #def commission_percentage
  #  branch_compensation.current_package.commission_percentage
  #end
  
  def can_see_me? (fld)
    title = datamart_user.datamart_user_profile.title rescue ''
    case title
      when 'Processor'
        return true if fld.eql?('per_loan_processed') or fld.eql?('per_loan_branch_processed')
      when 'Branch Manager / NON Storefront'        
      when 'Branch Manager Storefront'
        return true if fld.eql?('bmsf_override')
      when 'Branch Sales Manager'
        return true if fld.eql?('bsm_override')
    end
    false
  end

  def to_label
    "selection of #{branch_compensation.name} effective #{effective_date}"
  end

  private

  def effective_date_uniqueness
    if self.branch_compensation.present?
      br_id = self.branch_compensation.institution_id
      eff_dt = self.effective_date
      dt_id = self.datamart_user_id

      existing_subscription = DatamartUserCompensationPlan.
                                joins(:branch_compensation).
                                where{  (effective_date == eff_dt) & 
                                        (datamart_user_id == dt_id) &
                                        (branch_compensation.institution_id == br_id)
                                } - [self]

      unless existing_subscription.empty?
        errors.add(:effective_date, "already selected for a different plan for this branch")
        false
      end
    end
  end

  def effective_date_is_after_plan_effective_date
    if (!branch_compensation.nil? and branch_compensation.branch_compensation_details.count > 0 and branch_compensation.plan_package(effective_date).nil?)
      errors.add(:effective_date, "may not be before Plan's effective date")
      false
    end
  end

  def plan_must_have_details
    if (!branch_compensation.nil? and branch_compensation.branch_compensation_details.count.eql?(0))
      errors.add(:branch_compensation, "may not be selected because it has no details assigned")
      false
    end
  end

  def must_not_reselect_current_plan    
    if branch_compensation == employee.current_compensation_details_for_branch(branch_compensation.institution_id).try(:branch_compensation)
      errors.add(:branch_compensation, "may not be selected because it is already selected as a current plan")
      false
    end
  end
end
 
