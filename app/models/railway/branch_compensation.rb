class BranchCompensation < DatabaseRailway
  belongs_to :branch, class_name: 'Institution', foreign_key: 'institution_id'

  has_many :branch_compensation_details
  has_many :current_packages, -> { where("effective_date < ?", Date.tomorrow).order("effective_date DESC").limit(1) },
    :class_name => 'BranchCompensationDetail'

  has_many :datamart_user_compensation_plans, foreign_key: :branch_compensation_id
  has_many :employees, class_name: 'BranchEmployee', through: :datamart_user_compensation_plans

  validates :name, :branch, presence: true

  accepts_nested_attributes_for :branch_compensation_details

  #validates :branch_compensation_details, presence: true, :if => Proc.new {|r| r.new_record?}
  #validates_associated :branch_compensation_details, :if => Proc.new {|r| r.new_record?}

  before_update :prevent_update

  def self.not_terminated
    where{(termination_date == nil) | (termination_date > Date.today)}
  end

  def terminated?
    termination_date && Date.today > termination_date
  end

  def current_package
    current_packages.first
  end

  def package_by_employee user_id
    BranchCompensationDetail.
      joins(:branch_compensation => :datamart_user_compensation_plans).
      # where("#{BranchCompensationDetail.table_name}.effective_date <= ?", dt.end_of_day).
      # where("#{DatamartUserCompensationPlan.table_name}.effective_date <= ?", dt.end_of_day).
      where("#{DatamartUserCompensationPlan.table_name}.datamart_user_id = ?", user_id).
      where("#{BranchCompensation.table_name}.institution_id = ?", self.branch.id).
      order("#{BranchCompensationDetail.table_name}.effective_date").last
  end

  def plan_package(at_date)
    branch_compensation_details.where("effective_date < ?", at_date.tomorrow ).order(:effective_date).last
  end

  def current_or_future_package
    branch_compensation_details.order(:effective_date).last
  end

  def plan_history_between_dates start_date, end_date
    details = []
    
    details << branch_compensation_details.
      where("effective_date <= ?", end_date).
      order(:effective_date).last
    
    details << branch_compensation_details.
      where("effective_date <= ?", start_date).
      order(:effective_date).last

    details.compact.uniq

    # if end_date < Date.today
    #   raise end_date.to_s
    # end

  end

private

  def prevent_update
    return true unless institution_id_changed?
    errors.add(:branch, "Branch Compensation can not be re-assigned to a new Branch")
    false
  end
end
