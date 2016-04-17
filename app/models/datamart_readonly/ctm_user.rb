class CtmUser < DatabaseDatamartReadonly
  has_many :loan_notes
  has_many :scheduled_fundings, through: :loan_notes

  def self.sqlserver_create_view
    <<-eos
      SELECT     ctm.PID AS id,
                 ctm.Active_Flag AS is_active,
                 ctm.Domain_Login AS domain_login
      FROM       [CTM].[ctm].[CTM_User] AS ctm
    eos
  end

  def self.user_names
    self.select(:domain_login).all.map(&:domain_login).compact.uniq.sort
  end

  def to_s
    domain_login
  end
end
