class DatamartUser < DatabaseDatamartReadonly
  # has_one :datamart_user_profile

  # has_many :datamart_user_compensation_plans #, conditions: ["user_role_name in ('Originator','Originator Processor','Originator Manager') and title like 'Retail Standard%' and datamart_users.is_active = 1"]
  # has_many :branch_compensations, through: :datamart_user_compensation_plans

  has_many :account_infos, primary_key: :username, foreign_key: :broker_identifier
  has_many :loan_generals, through: :account_infos
  has_many :loans, through: :loan_generals
  has_many :licensed_states

  scope :retail_employees, where{ (title.matches 'Retail%') & (title.does_not_match 'Employee') & (user_role_name.matches 'Originator%')}
  scope :active, where(is_active: 1)

  scope :area_managers, where{ (is_active == 1) & (user_role_name == 'Account Executive')}.order(:last_name)

  def self.recent_expiring_originators
    recent_names = AccountInfo.recent_non_retail_originator_names
    expiring_users = LicensedState.expiring_user_ids
    self.where{id.in expiring_users}.where{username.in recent_names}
  end

  def self.sqlserver_create_view
    <<-eos
      SELECT
        USER_Id                         AS id,
        INSTITUTION_Id                  AS institution_id,
        UserName                        AS username,
        FirstName                       AS first_name,
        LastName                        AS last_name,
        Address                         AS address,
        City                            AS city,
        State                           AS state,
        Zip                             AS zip,
        Email                           AS email,
        Phone                           AS phone,
        Fax                             AS fax,
        UserLevel                       AS user_level,
        LenderLevel                     AS lender_level,
        IsActive                        AS is_active,
        LastLoginDate                   AS last_login_at,
        EmployeeNumber                  AS employee_number,
      --  EngineOptions bit NULL,
      --  DUEngineRight bit NULL,
      --  LPEngineRight bit NULL,
      --  RFCEngineRight bit NULL,
      --  IsDelegateAdministrator bit NULL,
        Title                           AS title,
        IsAccountExecutive              AS is_account_executive,
        UserRoleName                    AS user_role_name,
        FNMAoriginatorIdentifier        AS fnma_originator_identifier,
        CreationDate                    AS created_at,
        TerminationDate                 AS terminated_at,
        GUID                            AS uuid,
      --  ConsumerSiteAvailableIndicator bit NULL,
        AcctNotUseForLogin              AS acct_not_user_for_login
      FROM       LENDER_LOAN_SERVICE.dbo.[USER]
    eos
  end

  def last_loan_date
    account_infos.maximum(:request_at)
  end

  def expiration_date
    licensed_states.pluck(:license_expire_date).uniq.compact.map(&:to_date).join(',')
  end

  def name
    "#{first_name} #{last_name}".strip
  end

  def name_last_first
    "#{last_name}, #{first_name}".strip
  end

  def is_loan_officer?
    roles = user_role_name.split(" ").map(&:downcase)
    (roles.count == 1 && roles.include?('originator')) ? true : false
  end

  def is_processor?
    roles = user_role_name.split(" ").map(&:downcase)
    (roles.count > 1 && roles.include?('processor')) ? true : false
  end

  def is_manager?
    roles = user_role_name.split(" ").map(&:downcase)
    (roles.count > 1 && roles.include?('manager')) ? true : false
  end

  def profile_title_for_branch bid
    datamart_user_profiles.where{ (institution_id == bid) & ( effective_date <= Date.today )}.last.title rescue '---'
  end

  def current_compensation_details
    plan_compensation_details(Date.today)
  end

  def plan_compensation_details(at_date)
    datamart_user_compensation_plans.where('effective_date <= ?', at_date.tomorrow ).order('effective_date DESC').first.branch_compensation.branch_compensation_details.order('created_at DESC').first rescue nil
  end

  # relation, to make this backwards compatible since
  # its breaking reports.
  def branch
    (datamart_user_profiles.last.nil? || datamart_user_profiles.last.branch.nil?) ? nil : datamart_user_profiles.last.branch
  end

end

=begin
  USER_Id                         AS id,
  INSTITUTION_Id                  AS institution_id,
  UserName                        AS username,
  FirstName                       AS first_name,
  LastName                        AS last_name,
  Address                         AS address,
  City                            AS city,
  State                           AS state,
  Zip                             AS zip,
  Email                           AS email,
  Phone                           AS phone,
  Fax                             AS fax,
  UserLevel                       AS user_level,
  LenderLevel                     AS lender_level,
  IsActive                        AS is_active,
  LastLoginDate                   AS last_login_at,
  EmployeeNumber                  AS employee_number,
--  EngineOptions bit NULL,
--  DUEngineRight bit NULL,
--  LPEngineRight bit NULL,
--  RFCEngineRight bit NULL,
--  IsDelegateAdministrator bit NULL,
  Title                           AS title,
  IsAccountExecutive              AS is_account_executive,
  UserRoleName                    AS user_role_name,
--  FNMAoriginatorIdentifier varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  CreationDate                    AS created_at,
  TerminationDate                 AS terminated_at,
  GUID                            AS uuid,
--  ConsumerSiteAvailableIndicator] bit NULL,
  AcctNotUseForLogin              AS acct_not_user_for_login
=end
