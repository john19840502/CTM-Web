class LicensedState < DatabaseDatamartReadonly

  belongs_to :institution
  belongs_to :datamart_user

  def self.expiring
    where(license_expire_date: Date.today.end_of_month)
  end

  def self.user_level
    where(license_level: "User")
  end

  def self.institution_level
    where(license_level: "Institution")
  end

  def self.expiring_user_ids
    self.expiring.user_level.pluck(:datamart_user_id)
  end

  def self.expiring_institution_ids
    self.expiring.institution_level.pluck(:institution_id)
  end

  CREATE_VIEW_SQL =  <<-eos
      SELECT    LICENSED_STATES_id AS id,
                USER_Id            AS datamart_user_id,
                INSTITUTION_Id     AS institution_id,
                LicenseState       AS license_state,
                LicenseExpireDate  AS license_expire_date,
                LicenseNumber      AS license_number,
                LicenseLevel       AS license_level
      FROM      LENDER_LOAN_SERVICE.dbo.[LICENSED_STATES]
  eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
