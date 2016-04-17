# This is the originator listed on the 1003 form for the loan.
class MultiInstitution < DatabaseDatamartReadonly

  belongs_to :branch, class_name: 'Institution', foreign_key: :institution_id
  belongs_to :employee, class_name: 'DatamartUser', foreign_key: :datamart_user_id

  CREATE_VIEW_SQL =  <<-eos
      SELECT    USER_Id         AS datamart_user_id,
                INSTITUTION_Id  AS institution_id,
                IsProcessor     AS is_processor,
                IsOriginator    AS is_originator
      FROM       LENDER_LOAN_SERVICE.dbo.[MULTI_INSTITUTION]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
