class ChangeCompTierViewToLenderLnSrvc < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute "USE LENDER_LOAN_SERVICE"
      execute <<-SQL
        CREATE VIEW [dbo].[vwComp_Tier_Eval]
        AS
        SELECT ai.loanGeneral_Id,
               ct.Comp_Tier * 100 AS Comp_Tier,
               ct.Effective_Date AS Comp_Tier_Eff_Dt,
               gd.GFEDisclosureDate AS GFE_Disclosure_Date,
               hl._RatePercent AS GFE_801_Comp_Tier,
               hl._TotalAmount AS GFE_801_Amount,
               hl2._RatePercent AS GFE_826_Comp_Tier,
               hl2._TotalAmount AS GFE_826_Amount,
               hl3._RatePercent AS GFE_827_Comp_Tier,
               hl3._TotalAmount AS GFE_827_Amount,
               lp.LockDate AS Lock_Date,
               lp.LockExpirationDate AS Lock_Expire_Dt,
               CASE WHEN hl._RatePercent > 0 THEN 'Borrower Paid' ELSE 'Lender Paid' END AS GFE_Comp_Type,
               CASE WHEN hl._RatePercent > 0 THEN hl._RatePercent ELSE hl2._RatePercent END AS GFE_Comp_Tier,
               CASE WHEN lld.OriginatorCompensation = 1 THEN 'Borrower Paid'
                    WHEN lld.OriginatorCompensation = 2 THEN 'Lender Paid'
                    ELSE 'Not Defined' END AS Lock_Comp_Type, ABS(pa.Amount) AS Lock_Comp_Tier,
               CASE ISNULL(lld.OriginatorCompensation,3)
                 WHEN 1 THEN
                   CASE
                     WHEN ((hl._RatePercent > (ct.Comp_Tier * 100)) OR (hl2._RatePercent > (ct.Comp_Tier * 100))) THEN -1
                     ELSE 1
                   END
                 WHEN 2 THEN
                   CASE
                     WHEN (pa.Amount IS NULL) THEN 0
                     WHEN ((ABS(pa.Amount) > hl._RatePercent) AND (ABS(pa.Amount) > hl2._RatePercent)) THEN -2
                     WHEN (ABS(pa.Amount) > (ct.Comp_Tier * 100)) THEN -3
                     ELSE 1
                   END
                 WHEN 3 THEN
                   CASE
                     WHEN ((hl._RatePercent > 0) AND (hl2._RatePercent = 0)) THEN
                       CASE WHEN (hl._RatePercent > (ct.Comp_Tier * 100)) THEN -1 ELSE 1 END
                     WHEN ((hl2._RatePercent > 0) AND (hl._RatePercent = 0)) THEN
                       CASE WHEN (hl2._RatePercent > (ct.Comp_Tier * 100)) THEN -4 ELSE 1 END
                     ELSE 0
                   END
                 ELSE 0
               END AS Eval
          FROM LENDER_LOAN_SERVICE.dbo.ACCOUNT_INFO AS ai WITH (NOLOCK)
               INNER JOIN LENDER_LOAN_SERVICE.dbo.GFE_DETAIL AS gd WITH (NOLOCK)
                 ON gd.loanGeneral_Id = ai.loanGeneral_Id
               INNER JOIN LENDER_LOAN_SERVICE.dbo.HUD_LINE AS hl WITH (NOLOCK)
                 ON hl.loanGeneral_Id = gd.loanGeneral_Id
                AND hl.hudType = 'GFE' AND hl._LineNumber = 801
               INNER JOIN LENDER_LOAN_SERVICE.dbo.HUD_LINE AS hl2 WITH (NOLOCK)
                 ON hl2.loanGeneral_Id = gd.loanGeneral_Id
                AND hl2.hudType = 'GFE' AND hl2._LineNumber = 826
               INNER JOIN LENDER_LOAN_SERVICE.dbo.HUD_LINE AS hl3 WITH (NOLOCK)
                 ON hl3.loanGeneral_Id = gd.loanGeneral_Id
                AND hl3.hudType = 'GFE'
                AND hl3._LineNumber = 827
               LEFT OUTER JOIN LENDER_LOAN_SERVICE.dbo.LOCK_LOAN_DATA AS lld WITH (NOLOCK)
                 ON lld.loanGeneral_Id = gd.loanGeneral_Id
                AND lld.OriginatorCompensation IN (1, 2)
               LEFT OUTER JOIN LENDER_LOAN_SERVICE.dbo.LOCK_PRICE AS lp WITH (NOLOCK)
                 ON lp.loanGeneral_Id = gd.loanGeneral_Id
               LEFT OUTER JOIN LENDER_LOAN_SERVICE.dbo.PRICE_ADJUSTMENT AS pa WITH (NOLOCK)
                 ON pa.loanGeneral_Id = gd.loanGeneral_Id
                AND pa.Label LIKE 'Originator Compensation%'
               LEFT OUTER JOIN CTM.ctm.Comp_Tier AS ct WITH (NOLOCK)
                 ON ct.Institution_Number = ai.InstitutionIdentifier
                AND ct.Channel_Mortgage_Type =
                    CASE WHEN SUBSTRING(ai.Channel, 1, 1) <> 'A' THEN SUBSTRING(ai.Channel, 1, 2) 
                         ELSE CASE WHEN ((lp.ProductCode LIKE 'VA%') OR (lp.ProductCode LIKE 'FHA%'))
                                   THEN 'AG' ELSE 'AC' END END
                AND ct.Effective_Date =
                   (SELECT MAX(Effective_Date) AS Max_Eff_Dt
                      FROM CTM.ctm.Comp_Tier AS ct2 WITH (NOLOCK)
                     WHERE Institution_Number = ct.Institution_Number
                       AND Channel_Mortgage_Type = ct.Channel_Mortgage_Type
                       AND Effective_Date <= gd.GFEDisclosureDate)
      SQL
    end
    if Rails.env.development? || Rails.env.qa?
      execute "USE CTM"
      execute "DROP VIEW [dbo].[vwComp_Tier_Eval]"
    end
  end

  def down
    if Rails.env.development? || Rails.env.qa?
      execute <<-SQL
        CREATE VIEW [dbo].[vwComp_Tier_Eval]
        AS
        SELECT ai.loanGeneral_Id,
               ct.Comp_Tier * 100 AS Comp_Tier,
               ct.Effective_Date AS Comp_Tier_Eff_Dt,
               gd.GFEDisclosureDate AS GFE_Disclosure_Date,
               hl._RatePercent AS GFE_801_Comp_Tier,
               hl._TotalAmount AS GFE_801_Amount,
               hl2._RatePercent AS GFE_826_Comp_Tier,
               hl2._TotalAmount AS GFE_826_Amount,
               hl3._RatePercent AS GFE_827_Comp_Tier,
               hl3._TotalAmount AS GFE_827_Amount,
               lp.LockDate AS Lock_Date,
               lp.LockExpirationDate AS Lock_Expire_Dt,
               CASE WHEN hl._RatePercent > 0 THEN 'Borrower Paid' ELSE 'Lender Paid' END AS GFE_Comp_Type,
               CASE WHEN hl._RatePercent > 0 THEN hl._RatePercent ELSE hl2._RatePercent END AS GFE_Comp_Tier,
               CASE WHEN lld.OriginatorCompensation = 1 THEN 'Borrower Paid'
                    WHEN lld.OriginatorCompensation = 2 THEN 'Lender Paid'
                    ELSE 'Not Defined' END AS Lock_Comp_Type, ABS(pa.Amount) AS Lock_Comp_Tier,
               CASE ISNULL(lld.OriginatorCompensation,3)
                 WHEN 1 THEN
                   CASE
                     WHEN ((hl._RatePercent > (ct.Comp_Tier * 100)) OR (hl2._RatePercent > (ct.Comp_Tier * 100))) THEN -1
                     ELSE 1
                   END
                 WHEN 2 THEN
                   CASE
                     WHEN (pa.Amount IS NULL) THEN 0
                     WHEN ((ABS(pa.Amount) > hl._RatePercent) AND (ABS(pa.Amount) > hl2._RatePercent)) THEN -2
                     WHEN (ABS(pa.Amount) > (ct.Comp_Tier * 100)) THEN -3
                     ELSE 1
                   END
                 WHEN 3 THEN
                   CASE
                     WHEN ((hl._RatePercent > 0) AND (hl2._RatePercent = 0)) THEN
                       CASE WHEN (hl._RatePercent > (ct.Comp_Tier * 100)) THEN -1 ELSE 1 END
                     WHEN ((hl2._RatePercent > 0) AND (hl._RatePercent = 0)) THEN
                       CASE WHEN (hl2._RatePercent > (ct.Comp_Tier * 100)) THEN -4 ELSE 1 END
                     ELSE 0
                   END
                 ELSE 0
               END AS Eval
          FROM LENDER_LOAN_SERVICE.dbo.ACCOUNT_INFO AS ai WITH (NOLOCK)
               INNER JOIN LENDER_LOAN_SERVICE.dbo.GFE_DETAIL AS gd WITH (NOLOCK)
                 ON gd.loanGeneral_Id = ai.loanGeneral_Id
               INNER JOIN LENDER_LOAN_SERVICE.dbo.HUD_LINE AS hl WITH (NOLOCK)
                 ON hl.loanGeneral_Id = gd.loanGeneral_Id
                AND hl.hudType = 'GFE' AND hl._LineNumber = 801
               INNER JOIN LENDER_LOAN_SERVICE.dbo.HUD_LINE AS hl2 WITH (NOLOCK)
                 ON hl2.loanGeneral_Id = gd.loanGeneral_Id
                AND hl2.hudType = 'GFE' AND hl2._LineNumber = 826
               INNER JOIN LENDER_LOAN_SERVICE.dbo.HUD_LINE AS hl3 WITH (NOLOCK)
                 ON hl3.loanGeneral_Id = gd.loanGeneral_Id
                AND hl3.hudType = 'GFE'
                AND hl3._LineNumber = 827
               LEFT OUTER JOIN LENDER_LOAN_SERVICE.dbo.LOCK_LOAN_DATA AS lld WITH (NOLOCK)
                 ON lld.loanGeneral_Id = gd.loanGeneral_Id
                AND lld.OriginatorCompensation IN (1, 2)
               LEFT OUTER JOIN LENDER_LOAN_SERVICE.dbo.LOCK_PRICE AS lp WITH (NOLOCK)
                 ON lp.loanGeneral_Id = gd.loanGeneral_Id
               LEFT OUTER JOIN LENDER_LOAN_SERVICE.dbo.PRICE_ADJUSTMENT AS pa WITH (NOLOCK)
                 ON pa.loanGeneral_Id = gd.loanGeneral_Id
                AND pa.Label LIKE 'Originator Compensation%'
               LEFT OUTER JOIN CTM.ctm.Comp_Tier AS ct WITH (NOLOCK)
                 ON ct.Institution_Number = ai.InstitutionIdentifier
                AND ct.Channel_Mortgage_Type =
                    CASE WHEN SUBSTRING(ai.Channel, 1, 1) <> 'A' THEN SUBSTRING(ai.Channel, 1, 2) 
                         ELSE CASE WHEN ((lp.ProductCode LIKE 'VA%') OR (lp.ProductCode LIKE 'FHA%'))
                                   THEN 'AG' ELSE 'AC' END END
                AND ct.Effective_Date =
                   (SELECT MAX(Effective_Date) AS Max_Eff_Dt
                      FROM CTM.ctm.Comp_Tier AS ct2 WITH (NOLOCK)
                     WHERE Institution_Number = ct.Institution_Number
                       AND Channel_Mortgage_Type = ct.Channel_Mortgage_Type
                       AND Effective_Date <= gd.GFEDisclosureDate)
      SQL
    end
    if Rails.env.development?
      execute "USE LENDER_LOAN_SERVICE"
      execute "DROP VIEW [dbo].[vwComp_Tier_Eval]"   
    end
  end
end
