class UpdatevwCompTierEvalViewDevOnly < ActiveRecord::Migration
  def up
    return unless Rails.env.development?

    execute "USE LENDER_LOAN_SERVICE"

    execute <<-SQL
      DROP VIEW [dbo].[vwComp_Tier_Eval]
    SQL

    execute <<-SQL

CREATE VIEW [dbo].[vwComp_Tier_Eval]
AS
SELECT     ai.loanGeneral_Id, ct.SMDS_Product_ID, CASE WHEN ct.SMDS_Product_ID IS NULL
                      THEN 'ALL PRODUCTS' ELSE spc.ProductCode END AS Product_Code, ct.State_ID, CASE WHEN ct.State_ID IS NULL
                      THEN 'ALL STATES' ELSE s.State_Code END AS State_Code, ct.Comp_Tier * 100 AS Comp_Tier, ct.Effective_In_Date AS Comp_Tier_Eff_In_Dt,
                      ct.Effective_Out_Date AS Comp_Tier_Eff_Out_Dt, gd.GFEDisclosureDate AS GFE_Disclosure_Date, hl._RatePercent AS GFE_801_Comp_Tier,
                      hl._TotalAmount AS GFE_801_Amount, hl2._RatePercent AS GFE_826_Comp_Tier, hl2._TotalAmount AS GFE_826_Amount,
                      hl3._RatePercent AS GFE_827_Comp_Tier, hl3._TotalAmount AS GFE_827_Amount, lp.LockDate AS Lock_Date,
                      lp.LockExpirationDate AS Lock_Expire_Dt, CASE WHEN ((hl._RatePercent > 0) OR
                      (hl._TotalAmount > 0)) THEN 'Borrower Paid' WHEN ((hl2._RatePercent > 0) OR
                      (hl2._TotalAmount > 0)) THEN 'Lender Paid' ELSE 'Not Defined' END AS GFE_Comp_Type,
                      CASE WHEN hl._RatePercent > 0 THEN hl._RatePercent ELSE hl2._RatePercent END AS GFE_Comp_Tier,
                      CASE WHEN lld.OriginatorCompensation = 1 THEN 'Borrower Paid' WHEN lld.OriginatorCompensation = 2 THEN 'Lender Paid' ELSE 'Not Defined' END AS
                       Lock_Comp_Type, ABS(pa.Amount) AS Lock_Comp_Tier, CASE WHEN (((hl._RatePercent = 0) AND (hl._TotalAmount > 0)) OR
                      ((hl2._RatePercent = 0) AND (hl2._TotalAmount > 0))) THEN 0 ELSE CASE ISNULL(lld.OriginatorCompensation, 3)
                      WHEN 1 THEN CASE WHEN ((hl._RatePercent > (ct.Comp_Tier * 100)) OR
                      (hl2._RatePercent > (ct.Comp_Tier * 100))) THEN - 1 ELSE 1 END WHEN 2 THEN CASE WHEN (pa.Amount IS NULL) THEN 0 WHEN ((ABS(pa.Amount)
                      > hl._RatePercent) AND (ABS(pa.Amount) > hl2._RatePercent)) THEN - 2 WHEN (ABS(pa.Amount) > (ct.Comp_Tier * 100))
                      THEN - 3 ELSE 1 END WHEN 3 THEN CASE WHEN ((hl._RatePercent > 0) AND (hl2._RatePercent = 0))
                      THEN CASE WHEN (hl._RatePercent > (ct.Comp_Tier * 100)) THEN - 1 ELSE 1 END WHEN ((hl2._RatePercent > 0) AND (hl._RatePercent = 0))
                      THEN CASE WHEN (hl2._RatePercent > (ct.Comp_Tier * 100)) THEN - 4 ELSE 1 END ELSE 0 END ELSE 0 END END AS Eval
FROM         dbo.ACCOUNT_INFO AS ai WITH (NOLOCK) INNER JOIN
                      dbo.GFE_DETAIL AS gd WITH (NOLOCK) ON gd.loanGeneral_Id = ai.loanGeneral_Id INNER JOIN
                      dbo.HUD_LINE AS hl WITH (NOLOCK) ON hl.loanGeneral_Id = gd.loanGeneral_Id AND hl.hudType = 'GFE' AND hl._LineNumber = 801 INNER JOIN
                      dbo.HUD_LINE AS hl2 WITH (NOLOCK) ON hl2.loanGeneral_Id = gd.loanGeneral_Id AND hl2.hudType = 'GFE' AND hl2._LineNumber = 826 INNER JOIN
                      dbo.HUD_LINE AS hl3 WITH (NOLOCK) ON hl3.loanGeneral_Id = gd.loanGeneral_Id AND hl3.hudType = 'GFE' AND
                      hl3._LineNumber = 827 LEFT OUTER JOIN
                      dbo.LOAN_FEATURES AS lf WITH (NOLOCK) ON lf.loanGeneral_Id = gd.loanGeneral_Id LEFT OUTER JOIN
                      dbo.LOCK_LOAN_DATA AS lld WITH (NOLOCK) ON lld.loanGeneral_Id = gd.loanGeneral_Id AND lld.OriginatorCompensation IN (1, 2) LEFT OUTER JOIN
                      dbo.LOCK_PRICE AS lp WITH (NOLOCK) ON lp.loanGeneral_Id = gd.loanGeneral_Id LEFT OUTER JOIN
                      dbo.PRICE_ADJUSTMENT AS pa WITH (NOLOCK) ON pa.loanGeneral_Id = gd.loanGeneral_Id AND
                      pa.Label LIKE 'Originator Compensation%' LEFT OUTER JOIN
                      dbo.GFE_LOAN_DATA AS gld WITH (NOLOCK) ON gld.loanGeneral_Id = gd.loanGeneral_Id LEFT OUTER JOIN
                      CTM.smds.SMDSProductCodes AS spc WITH (NOLOCK) ON spc.ProductCode = COALESCE (lp.ProductCode, gld.LoanProgram) LEFT OUTER JOIN
                      dbo.PROPERTY AS p WITH (NOLOCK) ON p.loanGeneral_Id = gd.loanGeneral_Id LEFT OUTER JOIN
                      CTM.ctm.State AS s WITH (NOLOCK) ON s.State_Code = p._State LEFT OUTER JOIN
                      CTM.ctm.Comp_Tier AS ct WITH (NOLOCK) ON ct.Institution_Number = ai.InstitutionIdentifier AND (SUBSTRING(ct.Channel_Mortgage_Type, 2, 1)
                      = 'P' OR
                      ct.Channel_Mortgage_Type = CASE WHEN SUBSTRING(ai.Channel, 1, 1) <> 'A' THEN SUBSTRING(ai.Channel, 1, 2)
                      WHEN spc.ProductCodeClassI LIKE 'Gov%' THEN 'AG' ELSE 'AC' END) AND ISNULL(ct.SMDS_Product_ID, 0) = ISNULL
                          ((SELECT DISTINCT SMDS_Product_ID
                              FROM         CTM.ctm.Comp_Tier AS ct2 WITH (NOLOCK)
                              WHERE     (Institution_Number = ai.InstitutionIdentifier) AND (SUBSTRING(Channel_Mortgage_Type, 2, 1) = 'P') AND (SMDS_Product_ID IS NOT NULL)
                                                     AND (SMDS_Product_ID = spc.ID) AND (State_ID = s.ID OR
                                                    State_ID IS NULL) AND (Effective_In_Date =
                                                        (SELECT     MAX(Effective_In_Date) AS Max_Eff_Dt
                                                          FROM          CTM.ctm.Comp_Tier AS ct3 WITH (NOLOCK)
                                                          WHERE      (Institution_Number = ct.Institution_Number) AND (SUBSTRING(Channel_Mortgage_Type, 1, 1) = SUBSTRING(ai.Channel, 1,
                                                                                 1)) AND (SUBSTRING(Channel_Mortgage_Type, 2, 1) IN ('G', 'P')) AND (SMDS_Product_ID IS NOT NULL) AND
                                                                                 (SMDS_Product_ID = spc.ID) AND (State_ID = s.ID OR
                                                                                 State_ID IS NULL) AND (Effective_In_Date <= ISNULL(gd.GFEDisclosureDate, Effective_In_Date)) AND
                                                                                 (ISNULL(Effective_Out_Date, '2030-01-01') >= ISNULL(gd.GFEDisclosureDate, '2030-01-01')))) OR
                                                    (Institution_Number = ai.InstitutionIdentifier) AND (SMDS_Product_ID IS NOT NULL) AND (SMDS_Product_ID = spc.ID) AND
                                                    (State_ID = s.ID OR
                                                    State_ID IS NULL) AND (Effective_In_Date =
                                                        (SELECT     MAX(Effective_In_Date) AS Max_Eff_Dt
                                                          FROM          CTM.ctm.Comp_Tier AS ct3 WITH (NOLOCK)
                                                          WHERE      (Institution_Number = ct.Institution_Number) AND (SUBSTRING(Channel_Mortgage_Type, 1, 1) = SUBSTRING(ai.Channel, 1,
                                                                                 1)) AND (SUBSTRING(Channel_Mortgage_Type, 2, 1) IN ('G', 'P')) AND (SMDS_Product_ID IS NOT NULL) AND
                                                                                 (SMDS_Product_ID = spc.ID) AND (State_ID = s.ID OR
                                                                                 State_ID IS NULL) AND (Effective_In_Date <= ISNULL(gd.GFEDisclosureDate, Effective_In_Date)) AND
                                                                                 (ISNULL(Effective_Out_Date, '2030-01-01') >= ISNULL(gd.GFEDisclosureDate, '2030-01-01')))) AND
                                                    (Channel_Mortgage_Type = CASE WHEN SUBSTRING(ai.Channel, 1, 1) <> 'A' THEN SUBSTRING(ai.Channel, 1, 2)
                                                    WHEN spc.ProductCodeClassI LIKE 'Gov%' THEN 'AG' ELSE 'AC' END)), 0) AND ISNULL(ct.State_ID, 0) = ISNULL
                          ((SELECT DISTINCT State_ID
                              FROM         CTM.ctm.Comp_Tier AS ct2 WITH (NOLOCK)
                              WHERE     (Institution_Number = ai.InstitutionIdentifier) AND (SUBSTRING(Channel_Mortgage_Type, 2, 1) = 'P') AND (SMDS_Product_ID = spc.ID)
                                                    AND (State_ID IS NOT NULL) AND (State_ID = s.ID) AND (Effective_In_Date =
                                                        (SELECT     MAX(Effective_In_Date) AS Max_Eff_Dt
                                                          FROM          CTM.ctm.Comp_Tier AS ct3 WITH (NOLOCK)
                                                          WHERE      (Institution_Number = ct.Institution_Number) AND (SUBSTRING(Channel_Mortgage_Type, 1, 1) = SUBSTRING(ai.Channel, 1,
                                                                                 1)) AND (SUBSTRING(Channel_Mortgage_Type, 2, 1) IN ('G', 'P')) AND (SMDS_Product_ID = spc.ID) AND
                                                                                 (State_ID IS NOT NULL) AND (State_ID = s.ID) AND (Effective_In_Date <= ISNULL(gd.GFEDisclosureDate, Effective_In_Date))
                                                                                 AND (ISNULL(Effective_Out_Date, '2030-01-01') >= ISNULL(gd.GFEDisclosureDate, '2030-01-01')))) OR
                                                    (Institution_Number = ai.InstitutionIdentifier) AND (SMDS_Product_ID = spc.ID) AND (State_ID IS NOT NULL) AND (State_ID = s.ID) AND
                                                    (Effective_In_Date =
                                                        (SELECT     MAX(Effective_In_Date) AS Max_Eff_Dt
                                                          FROM          CTM.ctm.Comp_Tier AS ct3 WITH (NOLOCK)
                                                          WHERE      (Institution_Number = ct.Institution_Number) AND (SUBSTRING(Channel_Mortgage_Type, 1, 1) = SUBSTRING(ai.Channel, 1,
                                                                                 1)) AND (SUBSTRING(Channel_Mortgage_Type, 2, 1) IN ('G', 'P')) AND (SMDS_Product_ID = spc.ID) AND
                                                                                 (State_ID IS NOT NULL) AND (State_ID = s.ID) AND (Effective_In_Date <= ISNULL(gd.GFEDisclosureDate, Effective_In_Date))
                                                                                 AND (ISNULL(Effective_Out_Date, '2030-01-01') >= ISNULL(gd.GFEDisclosureDate, '2030-01-01')))) AND
                                                    (Channel_Mortgage_Type = CASE WHEN SUBSTRING(ai.Channel, 1, 1) <> 'A' THEN SUBSTRING(ai.Channel, 1, 2)
                                                    WHEN spc.ProductCodeClassI LIKE 'Gov%' THEN 'AG' ELSE 'AC' END)), 0) AND ct.Effective_In_Date =
                          (SELECT     MAX(Effective_In_Date) AS Max_Eff_Dt
                            FROM          CTM.ctm.Comp_Tier AS ct2 WITH (NOLOCK)
                            WHERE      (Institution_Number = ct.Institution_Number) AND (Channel_Mortgage_Type = ct.Channel_Mortgage_Type) AND
                                                   (Effective_In_Date <= ISNULL(gd.GFEDisclosureDate, Effective_In_Date)) AND (ISNULL(Effective_Out_Date, '2030-01-01')
                                                   >= ISNULL(gd.GFEDisclosureDate, '2030-01-01')))
 
    SQL

    # necessary so that we can insert into the schema migrations table
    execute "USE CTM"
  end

end
