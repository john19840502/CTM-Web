class BranchEmployee < DatabaseDatamartReadonly
  has_many :multi_institutions, foreign_key: :datamart_user_id
  has_many :branches, through: :multi_institutions

  has_many :datamart_user_profiles, foreign_key: :datamart_user_id

  has_many :datamart_user_compensation_plans, foreign_key: :datamart_user_id
  has_many :branch_compensations, through: :datamart_user_compensation_plans

  has_many :branch_employee_other_compensations, foreign_key: :datamart_user_id

  has_many :account_infos, primary_key: :username, foreign_key: :broker_identifier
  has_many :loan_generals, through: :account_infos
  has_many :loans, class_name: 'Master::Loan', primary_key: :username, foreign_key: :broker_identifier

  has_many :current_compensation_details_list, 
    ->{ where('effective_date <= ?', Date.today.end_of_day).order('effective_date DESC').limit(1)},
    :class_name => 'DatamartUserCompensationPlan',
    :foreign_key => :datamart_user_id

  scope :active,                      -> { where(is_active: true) }

  scope :from_retail_or_cd_branches,  -> { joins(:branches).where{branches.channel.in Channel.retail_all_ids} }
  scope :retail,                      -> { where{ (title.matches 'Retail%') & (user_role_name.matches 'Originator%') } }
  scope :retail_with_branch,          lambda { |branch_id| self.retail.joins { multi_institutions }.where { (multi_institutions.institution_id == branch_id) } }

  # delegate :ultipro_emp_id, to: :datamart_user_profile, allow_nil: true

  def self.sqlserver_create_view
    <<-eos
      SELECT
        USER_Id                         AS id,
        INSTITUTION_Id                  AS institution_id,
        AcctNotUseForLogin              AS acct_not_user_for_login,
        Address                         AS address,
        City                            AS city,
        CreationDate                    AS created_at,
        Email                           AS email,
        EmployeeNumber                  AS employee_number,
        Fax                             AS fax,
        FirstName                       AS first_name,
        GUID                            AS uuid,
        IsAccountExecutive              AS is_account_executive,
        IsActive                        AS is_active,
        LastLoginDate                   AS last_login_at,
        LastName                        AS last_name,
        LenderLevel                     AS lender_level,
        Phone                           AS phone,
        State                           AS state,
        TerminationDate                 AS terminated_at,
        Title                           AS title,
        UserLevel                       AS user_level,
        UserName                        AS username,
        UserRoleName                    AS user_role_name,
        Zip                             AS zip
      FROM       LENDER_LOAN_SERVICE.dbo.[USER]
    eos
  end

  # [AcctNotUseForLogin] [varchar](1) NULL,
  # [ConsumerDisplayNMLS] [varchar](1) NULL,
  # [ConsumerSiteAvailableIndicator] [bit] NULL,
  # [DUEngineRight] [bit] NULL,
  # [EngineOptions] [bit] NULL,
  # [FNMAoriginatorIdentifier] [varchar](30) NULL,
  # [IsDelegateAdministrator] [bit] NULL,
  # [LPEngineRight] [bit] NULL,
  # [RFCEngineRight] [bit] NULL,

  def supervisor bid
    # Just a hack to get this out there, ultimately I think it will change with new Atlas project
    # if not, then we need to re-vamp the loan officer stuff to make it more robust.
    # begin      
      self.branches.where(id: bid).last.employees.find(:all,
        :joins => :datamart_user_profiles,
        :include => :datamart_user_profiles,
        :conditions => {:datamart_user_profiles => {:title => UserProfile::MANAGER_TITLES}}) #.first.name
    # rescue
    #   ""
    # end
  end

  def loans_for_branch bid
    inst_num = Institution.where(id: bid).last.try(:institution_number)
    loans.where(institution_identifier: inst_num)
  end

  def branch_compensations_for_branch bid
    branch_compensations.where(institution_id: bid)
  end

  def current_compensation_details_for_branch bid
    compensation_details_for_branch_and_date bid, Date.today  
  end

  def compensation_details_for_branch_and_date bid, dt
    dt_comp = datamart_user_compensation_plans.joins(:branch_compensation).
      where('effective_date <= ? and institution_id = ?', dt.end_of_day, bid).
      order(:effective_date).last

    if dt_comp
      BranchCompensationDetail.
        joins(:branch_compensation).
        where("#{BranchCompensationDetail.table_name}.effective_date <= ?", dt.end_of_day).
        where("#{BranchCompensation.table_name}.id = ?", dt_comp.branch_compensation_id).
        order("#{BranchCompensationDetail.table_name}.effective_date").last
    else
      nil
    end

    # BranchCompensationDetail.
    #   joins(:branch_compensation => :datamart_user_compensation_plans).
    #   where("#{BranchCompensationDetail.table_name}.effective_date <= ?", dt.end_of_day).
    #   where("#{DatamartUserCompensationPlan.table_name}.effective_date <= ?", dt.end_of_day).
    #   where("#{DatamartUserCompensationPlan.table_name}.datamart_user_id = ?", self.id).
    #   where("#{BranchCompensation.table_name}.institution_id = ?", bid).
    #   order("#{BranchCompensationDetail.table_name}.effective_date").last
  end

  def compensation_details_for_branch bid
    BranchCompensationDetail.
      joins(:branch_compensation => :datamart_user_compensation_plans).
      where("#{DatamartUserCompensationPlan.table_name}.datamart_user_id = ?", self.id).
      where("#{BranchCompensation.table_name}.institution_id = ?", bid).
      order("#{DatamartUserCompensationPlan.table_name}.effective_date desc")
  end

  def compensation_history_for_branch bid
    DatamartUserCompensationPlan.
      joins(:branch_compensation).
      where("#{DatamartUserCompensationPlan.table_name}.datamart_user_id = ?", self.id).
      where("#{BranchCompensation.table_name}.institution_id = ?", bid).
      order("#{DatamartUserCompensationPlan.table_name}.effective_date desc")
  end

  def current_profile_for_branch bid
    datamart_user_profiles.where{ (institution_id == bid) & (effective_date <= Date.today) }.last
  end

  def profiles_for_branch bid
    datamart_user_profiles.where(institution_id: bid).order('effective_date desc')
  end

  def non_plan_comps_for_branch bid
    branch_employee_other_compensations.where(institution_id: bid)
  end

  def current_non_plan_comps_for_branch bid
    branch_employee_other_compensations.
      where(institution_id: bid).
      where("effective_date <= ?", Date.today.end_of_day).
      order(:effective_date).last
  end

  def current_compensation_details
    current_compensation_details_list.first
  end

  def current_or_future_compensation_plan
    current_compensation_details_list.first || datamart_user_compensation_plans.order(:effective_date).last
  end

  def plan_compensation_details(at_date)
    datamart_user_compensation_plans.where("effective_date <= ?", at_date.to_date.end_of_day).order(:effective_date).last
  end

  def current_compensation_name
    compensation = current_compensation_details.try(:branch_compensation)
    if compensation && !compensation.terminated?
      compensation.name
    end
  end

  def name
    "#{first_name} #{last_name}".strip
  end

  def name_last_first
    "#{last_name}, #{first_name}".strip
  end

end
