class RedwoodLoan < DatabaseDatamartReadonly

  default_scope ->{ order('[Seller Loan Number]') }

  CREATE_VIEW_SQL = <<-eos
      SELECT
        '165' AS [Seller ID],
        CASE WHEN UPPER(y.Event) IN ('REGISTER', 'UPDATE') THEN UPPER(y.Event) ELSE '' END AS Event,
        ISNULL(x.RWTLenderLnStatus, '') AS [Seller Loan Status],
        SUBSTRING(x.LnNbr, 1, 25) AS [Seller Loan Number],
        '' AS [RWT Loan Number],
        ISNULL(SUBSTRING(x.Brw1FName, 1, 25), '') AS [Borrower1 First Name],
        ISNULL(SUBSTRING(x.Brw1LName, 1, 25), '') AS [Borrower1 Last Name],
        ISNULL(SUBSTRING(REPLACE(x.Brw1SSN, '-', ''), 1, 9), '') AS [Borrower1 SSN],
        ISNULL(SUBSTRING(x.Brw2FName, 1, 20), '') AS [Borrower2 First Name],
        ISNULL(SUBSTRING(x.Brw2LName, 1, 75), '') AS [Borrower2 Last Name],
        ISNULL(SUBSTRING(REPLACE(x.Brw2SSN, '-', ''), 1, 9), '') AS [Borrower2 SSN],
        ISNULL(x.RepresentativeFICO, '') AS [Credit Score],
        ISNULL(x.RWTLoanPurpose, '') AS [Purpose Code],
        ISNULL(x.RWTOccupancyType, '') AS [Occupancy Code],
        ISNULL(x.RWTPropertyType, '') AS [Property Code],
        CASE SUBSTRING(x.DerivedPropTypeRWT, LEN(x.DerivedPropTypeRWT) - 7, 8) WHEN 'Attached' THEN 'ATCH' WHEN 'Detached' THEN 'DTCH' ELSE '' END AS [Property Attachment],
        CASE x.NbrOfUnits WHEN 0 THEN '' ELSE STR(x.NbrOfUnits, 2, 0) END AS [Number of Units],
        CASE x.PropertyStreetAddress WHEN 'NA' THEN '' ELSE SUBSTRING(x.PropertyStreetAddress, 1, 30) END AS [Property Address],
        '' AS [Property Address2], CASE x.PropertyCity WHEN 'NA' THEN '' ELSE SUBSTRING(x.PropertyCity, 1, 50) END AS [Property City],
        CASE x.PropertyState WHEN 'NA' THEN '' ELSE SUBSTRING(x.PropertyState, 1, 2) END AS [Property State],
        CASE x.PropertyPostalCode WHEN 'NA' THEN '' ELSE SUBSTRING(x.PropertyPostalCode, 1, 5) END AS [Property ZIP],
        CASE WHEN x.LnPurpose = 'Purchase' THEN CASE x.SalePrice WHEN 0 THEN '' ELSE STR(x.SalePrice, 8, 0) END ELSE '' END AS [Sales Price],
        CASE x.AppraisdValue WHEN 0 THEN '' ELSE STR(x.AppraisdValue, 8, 0) END AS [Appraised Value],
        CASE x.LnAmt WHEN 0 THEN '' ELSE STR(x.LnAmt, 8, 0) END AS [Original Loan Amt],
        ISNULL(x.RWTProgramName, '') AS [Product Name],
        'FDOC' AS [Document Type],
        CASE SUBSTRING(x.LendingChannel, 1, 2) WHEN 'A0' THEN 'RETL' WHEN 'W0' THEN 'BRKR' WHEN 'R0' THEN 'CORR' ELSE '' END AS [Origination Channel],
        CASE x.FinalNoteRate WHEN 0 THEN '' ELSE STR(x.FinalNoteRate, 9, 4) END AS [Note Rate],
        CASE WHEN ISNULL(y.LockTerm, 0) = 0 THEN '' ELSE STR(y.LockTerm, 2, 0) END AS [Lock Term],
        '' AS [Commitment ID],
        CASE x.DTI WHEN 0 THEN '' ELSE STR(x.DTI, 9, 4) END AS DTI,
        CASE x.GrossSellPrice WHEN 0 THEN '' ELSE STR(x.GrossSellPrice, 9, 4) END AS [Seller Reported Base Price],
        CASE x.GrossSellPrice WHEN 0 THEN '' ELSE CASE x.NetSellPrice WHEN 0 THEN '' ELSE CASE WHEN x.GrossSellPrice >= x.NetSellPrice THEN STR(x.GrossSellPrice - x.NetSellPrice, 9, 4) ELSE STR(x.NetSellPrice - x.GrossSellPrice, 9, 4) END END END AS [Seller Reported Total Price Adjustments],
        CASE x.NetSellPrice WHEN 0 THEN '' ELSE STR(x.NetSellPrice, 9, 4) END AS [Seller Reported Final Price],
        CASE x.SubordinateFinance WHEN 0 THEN '' ELSE STR(x.SubordinateFinance, 8, 0) END AS [Secondary Financing],
        CASE WHEN CONVERT(varchar, x.ClsgDt, 101) = '01/01/1900' THEN '' ELSE CONVERT(varchar, DATEPART(month, x.ClsgDt)) + '/' + CONVERT(varchar, DATEPART(day, x.ClsgDt)) + '/' + CONVERT(varchar, DATEPART(year, x.ClsgDt)) END AS [Estimated Close Date],
        CASE x.LnAmortTerm WHEN 0 THEN '' ELSE STR(x.LnAmortTerm, 3, 0) END AS [Loan Term],
        CASE x.CashOutAmt WHEN 0 THEN '' ELSE STR(x.CashOutAmt, 8, 0) END AS [Cash Out Amount],
        CASE x.LienPriority WHEN 'FirstLien' THEN '1' WHEN 'SecondLien' THEN '2' ELSE '' END AS [Lien Position],
        CASE WHEN x.EscrowWaiverFlg = 'N' THEN 'Y' ELSE 'N' END AS Escrowed, '' AS [Prepayment Penalty Term],
        CASE WHEN x.ProductCode LIKE '%ARM%' THEN CASE x.MarginPct WHEN 0 THEN '' ELSE STR(x.MarginPct, 9, 4) END ELSE '' END AS Margin,
        x.RelocationLoanFlag AS [Relocation Indicator]
      FROM smds.SMDSLoanDetails AS x INNER JOIN
           smds.SMDSRedwoodLoansImported AS y ON x.LnNbr = y.LnNbr
  eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

end

=begin
Event
Lender Loan Status
Lender Loan Number
RWT Loan Number
Borrower1 First Name
Borrower1 Last Name
Borrower1 SSN
Borrower2 First Name
Borrower2 Last Name
Borrower2 SSN
Credit Score
Purpose Code
Occupancy Code
Property Code
Number of Units
Property Address
Property Address2
Property City
Property State
Property ZIP
Sales Price
Appraised Value
Original Loan Amt
LTV
CLTV
Program Name
Document Type
Origination Channel
Note Rate
Margin
Lock Date
Lock Term
Lock Expiration Date
Commitment ID
DTI
Base Price
Total Price Adjustments
Net Price
Secondary Financing
Estimated Close Date
Escrowed
Extension Days
Index
Prepayment Penalty Term
UPB
Original Price
Payment String
ELTV
Mortgage Insurance Percent
Pledge Indicator
Pledge Amount
Net Margin
Loan Term
4506-T Indicator
All Borrower Total Income
All Borrower Wage Income
Cash Out Amount
Co-Borrower Other Income
Covered/High Cost Loan Indicator
Credit Line Usage Ratio
Credit Report: Longest Trade Line
Credit Report: Maximum Trade Line
Credit Report: Number of Trade Lines
Current Other Monthly Payment
Current Interest Rate
FICO Model Used
Length of Employment: Borrower
Length of Employment: Co-Borrower
Monthly Debt All Borrowers
Most Recent FICO Date
Most Recent FICO Method
Most Recent VantageScore Method
Number of Mortgaged Properties
Original Property Valuation Date (appraisal date)
Percentage of Down Payment from Borrower Own Funds
Prepayment Penalty Type
Primary Borrower Other Income
Primary Wage Earner Original FICO: Equifax
Primary Wage Earner Original FICO: Experian
Primary Wage Earner Original FICO: TransUnion
Secondary Wage Earner Original FICO: Equifax
Secondary Wage Earner Original FICO: Experian
Secondary Wage Earner Original FICO: TransUnion
Total Number of Borrowers
Total Origination and Discount Points
VantageScore Date
VantageScore: Co-Borrower
VantageScore: Primary Borrower
Years in Home
Verified Assets
Assumable
Buydown flag
Convertible Flag
Escrow PMT
First Adj Cap
First Payment
First Time Home Buyer
LPMI Amount
Lien Position
Life Cap
Min Rate
Lookback
Maturity Date
Max Rate
MERS Number
MI Cert #
Scheduled Next payment Due
Next Pay Change
Note Date
Periodic Cap
Current P & I
Scheduled UPB
Relo
Rounding factor
Self Employed
Flood Cert #
Flood Cert Provider
Flood Zone
County
Appraisal Type
Bankruptcy Flag
Foreclosure Flag
Foreign National Flag
Front Ratio
Servicing
Current PITI
Remaining Term
Paid to Date
Request for Exception Flag
REO Flag
=end
