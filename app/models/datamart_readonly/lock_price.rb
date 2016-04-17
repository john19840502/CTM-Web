class LockPrice < DatabaseDatamartReadonly
  belongs_to :loan_general

  has_one :loan, through: :loan_general

  def is_loan_locked?
    !locked_at.nil? and (lock_expired_at.nil? or lock_expired_at > Date.today) and !lock_confirmation_code.blank?
  end


  CREATE_VIEW_SQL = <<-eos
      SELECT     LOCK_PRICE_id AS id,
               loanGeneral_Id             AS loan_general_id,
               BaseIndexMargin            AS base_index_margin,
               BasePrice                  AS base_price,
               BaseProductCode            AS base_product_code,
               BaseRate                   AS base_rate,
               FinalIndexMargin           AS final_index_margin,
               FinalNoteRate              AS final_note_rate,
               LenderProductCode          AS lender_product_code,
               LockConfirmationCode       AS lock_confirmation_code,
               LockDate                   AS locked_at,
               LockExpirationDate         AS lock_expired_at,
               LockPeriod                 AS lock_period,
               NetPrice                   AS net_price,
               ProductCode                AS product_code,
               ProductDescription         AS product_description,
               RateSheetIdentifier        AS rate_sheet_id,
               RegistrationDate           AS registered_at
      FROM       LENDER_LOAN_SERVICE.dbo.[LOCK_PRICE]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
