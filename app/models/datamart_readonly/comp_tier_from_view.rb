class CompTierFromView < DatabaseDatamartReadonly
  belongs_to :loan_general

  default_scope ->{ order('loan_general_id ASC') }

  CREATE_VIEW_SQL = <<-eos
      SELECT   loanGeneral_Id AS loan_general_id,
               Comp_Tier AS comp_tier,
               GFE_Disclosure_Date AS disclosure_date,
               GFE_801_Comp_Tier AS borrower_comp_rate,
               GFE_801_Amount AS borrower_comp_amt,
               GFE_826_Comp_Tier AS originator_comp_rate,
               GFE_826_Amount AS originator_comp_amt,
               GFE_827_Comp_Tier AS lender_comp_rate,
               GFE_827_Amount AS lender_comp_amt,
               Lock_Date AS lock_date,
               Lock_Expire_Dt AS lock_expire_date,
               GFE_Comp_Type AS gfe_comp_type,
               GFE_Comp_Tier AS gfe_comp_tier,
               Lock_Comp_Type AS lock_comp_type,
               Lock_Comp_Tier AS lock_comp_tier,
               Eval AS comp_tier_eval
      FROM       LENDER_LOAN_SERVICE.dbo.[vwComp_Tier_Eval]
    eos



  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
