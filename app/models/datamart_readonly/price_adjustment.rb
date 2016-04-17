class PriceAdjustment < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT   PRICE_ADJUSTMENT_id AS id,
               loanGeneral_Id AS loan_general_id,
               Date AS date,
               Amount AS amount,
               Label AS label,
               Type AS price_adjustment_type,
               PriceType AS price_type,
               RuleIdentifier AS rule_id
      FROM       LENDER_LOAN_SERVICE.dbo.[PRICE_ADJUSTMENT]
    eos



  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
