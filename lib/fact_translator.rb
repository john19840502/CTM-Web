class FactTranslator

  def self.property_type(key)
    case key
    when 'High Rise Condo', 'HighRiseCondominium', 'Condo', 'Condominium'
      'Condo'
    when 'CondHotel', 'Condo Hotel'
      'Condo Hotel'
    when 'Co-Operative (Co-OP)', 'Cooperative', 'Co-Operative'
      'Co-Operative'
    when  'Manufactured Housing', 'ManufacturedHomeMultiwide', 'Manufactured Home: Condo/PUD/Co-Op', 'ManufacturedHousingSingleWide', 'ManufacturedHousing', 'Manufactured', 'Other', 'Manufactured Home'
      'Manufactured Home'
    when 'Modular'
      'Modular'
    when 'PUD Detached', 'PUDDetached'
      'PUD Detached'
    when 'PUD Attached', 'PUDAttached'
      'PUD Attached'
    when 'Attached', 'SFR Attached/Row'
      'SFR Attached/Row'
    when 'Single Family Detached', 'Detached'
      'Single Family Detached'
    when 'Site Condo', 'SiteCondo', 'DetachedCondominium', 'Detached Condo'
      'Site Condo'
    when 'Planned Unit Development (PUD)', 'PUD', 'PUD Unspecified'
      'PUD Unspecified'
    else
      nil
    end
  end

  def self.property_type_indicator(key)
    case key
    when 'Attached', 'PUDAttached', 'Pud Attached', 'PUD Attached'
      'PUD Attached'
    when 'Condominium'
      'Condominium'
    when 'Detached', 'PUDDetached', 'PUD Detached'
      'PUD Detached'
    when 'ManufacturedHousingSingle', 'Manufactured House Singlewide'
      'Manufactured House Singlewide'
    when 'ManufacturedHomeMultiwide', 'Manufactured House Multiwide'
      'Manufactured House Multiwide'
    else
      nil
    end
  end

  def self.project_classification(key)
    case key
    when 'Streamlined Review'
      'Streamlined Review'
    when '2- to 4-unit Project', '2- to 4-unit Project', '2 to 4 unit Project'
      '2 to 4 unit Project'
    when 'Detached Project'
      'Detached Project'
    when 'Established Project'
      'Established Project'
    when 'New Project'
      'New Project'
    when 'Reciprocal Review'
      'Reciprocal Review'
    when 'P Limited Review New Detached', 'PCondominium', 'P Limited Review New'
      'P Limited Review New'
    when 'Q Limited Review Established', 'QCondominium', 'Q Limited Review Est.'
      'Q Limited Review Est.'
    when 'R Expedited Review New', 'RCondominium', 'R Expedited New'
      'R Expedited New'
    when 'S Expedited Review Established', 'SCondominium', 'S Expedited Est.'
      'S Expedited Est.'
    when 'T Fannie Mae Review', 'TCondominium', 'T Fannie Mae Review'
      'T Fannie Mae Review'
    when 'U FHA-Approved', 'UCondominium'
      'U FHA-Approved'
    when 'V Refi Plus'
      'V Refi Plus'
    when 'V Condo'
      'V Condo'
    when 'E PUD', 'E_PUD'
      'E PUD'
    when 'F PUD', 'F_PUD'
      'F PUD'
    when 'T PUD'
      'T PUD'
    when '1 CO-OP', 'OneCooperative', '1 Co-Op'
      '1 Co-Op'
    when '2 CO-OP', 'TwoCooperative', '2 Co-Op'
      '2 Co-Op'
    when 'T CO-OP', 'T Co-Op'
      'T Co-Op'
    else
      nil
    end 
  end

  def self.loan_product_name(key)
    case key
    when 'Conforming 15yr Fixed','C15FXD'
      'C15FXD'
    when 'Conforming 15yr Fixed High Balance','C15FXD HIBAL'
      'C15FXD HIBAL'
    when 'Conforming 20yr Fixed DU RefiPlus','C20FXD RP'
      'C20FXD RP'
    when 'Conforming 20yr Fixed High Balance','C20FXD HIBAL'
      'C20FXD HIBAL'
    when 'Conforming 30yr Fixed','C30FXD'
      'C30FXD'
    when 'Conforming 30yr Fixed DU RefiPlus','C30FXD RP'
      'C30FXD RP'
    when 'Conforming 30yr Fixed High Balance','C30FXD HIBAL'
      'C30FXD HIBAL'
    when 'J30FXD', 'Jumbo 30yr Fixed'
      'J30FXD'
    when 'Jumbo 5/1 ARM LIBOR', 'J5/1ARM LIB','J5/1ARM LIBOR'
      'J5/1ARM LIBOR'
    when 'Jumbo 7/1 ARM LIBOR', 'J7/1 ARM LIB','J7/1ARM LIBOR'
      'J7/1ARM LIBOR'
    when 'FHA 15yr Fixed 203b','FHA15FXD'
      'FHA15FXD'
    when 'Jumbo 15yr Fixed','J15FXD'
      'J15FXD'
    when 'VA 15yr Fixed','VA15FXD'
      'VA15FXD'
    when 'VA 30yr IRRL', 'VA30IRRL','VA30IRRRL'
      'VA30IRRRL'
    when 'USDA 30yr Fixed','USDA30FXD'
      'USDA30FXD'
    when 'Conforming 20yr Fixed Freddie Mac Relief', 'C20FXD FR','C20FXD Freddie Relief'
      'C20FXD Freddie Relief'
    when 'Conforming 30yr Fixed Freddie Mac Relief', 'C30FXD FR','C30FXD Freddie Relief'
      'C30FXD Freddie Relief'
    when 'VA 30yr Fixed','VA30FXD'
      'VA30FXD'
    when 'Conforming 30yr Fixed HomePath', 'C30FXD HP','C30FXD HomePath'
      'C30FXD HomePath'
    when 'Conforming 10/1 ARM LIBOR','C10/1ARM LIBOR'
      'C10/1ARM LIBOR'
    when 'Conforming 10/1 ARM LIBOR High Balance','C10/1ARM LIB HIBAL'
      'C10/1ARM LIB HIBAL'
    when 'Conforming 5/1 ARM LIBOR', 'C5/1ARM LIB','C5/1ARM LIBOR'
      'C5/1ARM LIBOR'
    when 'Conforming 5/1 ARM LIBOR High Balance','C5/1ARM LIB HIBAL'
      'C5/1ARM LIB HIBAL'
    when 'Conforming 7/1 ARM LIBOR', 'C7/1ARM LIB','C7/1ARM LIBOR'
      'C7/1ARM LIBOR'
    when 'Conforming 7/1 ARM LIBOR High Balance','C7/1ARM LIB HIBAL'
      'C7/1ARM LIB HIBAL'
    when 'Conforming 20yr Fixed','C20FXD'
      'C20FXD'
    when 'Conforming 15yr Fixed DU RefiPlus','C15FXD RP'
      'C15FXD RP'
    when 'Conforming 15yr Fixed Freddie Mac Relief', 'C15FXD FR','C15FXD Freddie Relief'
      'C15FXD Freddie Relief'
    when 'FHA 30yr Streamline Refi', 'FHA30STR','FHA Streamline'
      'FHA Streamline'
    when 'State Housing FHA 30yr Fixed MSHDA', 'FHA30 MSHDA','MSHDA-FHA 30 Fixed'
      'MSHDA-FHA 30 Fixed'
    when 'FHA 30yr Fixed 203b','FHA30FXD'
      'FHA30FXD'
    when 'State Housing FHA 30yr Fixed - IN Next Home', 'FHA30 IHCDA IN NH','FHA 30 IHCDA IN NH'
      'FHA 30 IHCDA IN NH'
    when 'State Housing FHA 30yr Fixed - IL SmartMove', 'FHA30 IHDA IL SM','FHA 30 IHDA IL SM'
      'FHA 30 IHDA IL SM'
    when 'Conforming 30yr Fixed RefiPlus Consumer Direct','C30FXD RP CD'
      'C30FXD RP CD'
    when 'Conforming 15yr Fixed RefiPlus Consumer Direct','C15FXD RP CD'
      'C15FXD RP CD'
    when 'Conforming 30yr Fixed My Community Mortgage','C30FXD MCM'
      'C30FXD MCM'
    when 'FHA30 MSHDA NH','FHA30 MSHDA NH'
      'FHA30 MSHDA NH'
    when 'J10/1 ARM LIB','J10/1ARM LIBOR'
      'J10/1ARM LIBOR'
    when 'C30FXD IHDA IL','C30FXD IHDA IL'
      'C30FXD IHDA IL'
    when 'C30FXD IHDA IL FH','C30FXD IHDA IL FH'
      'C30FXD IHDA IL FH'
    when 'FHA30 IHDA IL FH','FHA30 IHDA IL FH'
      'FHA30 IHDA IL FH'
    when 'C15FXD HR'
      'C15FXD HR'
    when 'C20FXD HR'
      'C20FXD HR'
    when 'C30FXD HR'
      'C30FXD HR'
    when 'C5/1ARM LIB HR'
      'C5/1ARM LIB HR'
    when 'C7/1ARM LIB HR'
      'C7/1ARM LIB HR'
    when 'C10/1ARM LIB HR'
      'C10/1ARM LIB HR'
    when 'FHA30 GA Dream'
      'FHA30 GA Dream'
    when 'FHA30 GA CHOICE'
      'FHA30 GA Dream CHOICE'
    when 'FHA30 GA PEN'
      'FHA30 GA Dream PEN'
    when 'C30FXD KY HC'
      'C30FXD KHC'
    when 'FHA30 KY HC'
      'FHA30FXD KHC'
    when 'FHA15STR'
      'FHA15STR'
    else
      nil
    end
  end

  def self.purpose_of_loan(key)
    case key
    when 'ConstructionOnly','Construction'
      'Construction'
    when 'ConstructionToPermanent','Construction-Permanent'
      'Construction-Permanent'
    when 'Other'
      'Other'
    when 'Purchase'
      'Purchase'
    when 'Refinance'
      'Refinance'
    else
      nil
    end  
  end

  def self.arm_index_code(key)
    case key
    when 'OneYearTreasury','1-Year Treasury'
      '1-Year Treasury'
    when 'ThreeYearTreasury','3-Year Treasury'
      '3-Year Treasury'
    when 'SixMonthTreasury','6-Month T-Bill'
      '6-Month T-Bill'
    when 'LIBOR'
      'LIBOR'
    when 'NationalMonthlyMedianCostOfFunds','National Median COF'
      'National Median COF'
    when 'EleventhDistrictCostOfFunds','COFI'
      'COFI'
    when 'Other'
      'Other'
    else
      nil
    end
  end

  def self.channel_name(key)
    case key
    when 'C0-Consumer Direct Standard', 'TC0-Test Consumer Direct Standard','Consumer Direct'
      'Consumer Direct'
    when 'R0-Reimbursement Standard', 'TR0-Test Reimbursement Standard','Mini Correspondent'
      'Mini Correspondent'
    when 'P0-Private Banking Standard', 'TP0-Test Private Banking','Private Banking'
      'Private Banking'
    when 'A0-Affiliate Standard', 'A4-Affiliate Tier 4', 'Retail Channel', 'TA0-Test Affiliate Standard', 'TA1-Test Affiliate Tier 1 Dodd Frank','Retail'
      'Retail'
    when 'TW0-Test Wholesale Standard', 'TW1-Test Wholesale Dodd Frank', 'TWC1 - Test Wholesale Borrower Paid Channel', 'W0-Wholesale Standard', 'W4-Wholesale Tier 4','Wholesale'
      'Wholesale'
    else
      nil
    end
  end

  def self.harp_type_of_mi(key)
    case key
    when 'null', "Required Field, Please Select...",'Required Field Please Select'
      'Required Field Please Select'
    when 'Non Harp', 'This is a non HARP Loan', 'Non HARP','This is a non HARP Loan'
      'This is a non HARP Loan'
    when 'Borrower Paid Monthly', 'Borrower Paid, Monthly MI','Borrower Paid Monthly MI'
      'Borrower Paid Monthly MI'
    when 'Borrower Paid Single', "Borrower Paid, Single Premium - Paid Up Front",'Borrower Paid Single Premium - Paid Up Front'
      'Borrower Paid Single Premium - Paid Up Front'
    when 'Lender Paid Single', "Lender Paid, Single Premium - Paid Up Front",'Lender Paid Single Premium - Paid Up Front'
      'Lender Paid Single Premium - Paid Up Front'
    when 'No MI', 'No MI is required on the AUS','No MI is required on the AUS'
      'No MI is required on the AUS'
    when 'MI Cancelled', 'MI was cancelled, documentation provided in imaging', 'MI was cancelled, documentation provided in imagin','MI was cancelled documentation provided in imaging'
      'MI was cancelled documentation provided in imaging'
    else
      nil
    end
  end

  def self.requested_mortgage_insurance_type(key)
    case key
    when 'Monthly','Borrower Paid MONTHLY','B','Borrower Paid MONTHLY'
      'Borrower Paid MONTHLY'
    when 'null', 'Required Field Please Select...','Required Field Please Select'
      'Required Field Please Select'
    when 'None', 'Not Required', 'NA','No MI Required'
      'No MI Required'
    when 'Lender', 'Lender Paid SINGLE Premium','L','Lender Paid SINGLE Premium (LPMI)'
      'Lender Paid SINGLE Premium (LPMI)'
    when 'Borrower Paid SPLIT Premium MI', 'Split','Borrower Paid SPLIT Premium MI'
      'Borrower Paid SPLIT Premium MI'
    else
      nil
    end
  end

  def self.occupancy_type(key)  
    case key
    when 'SecondHome','Second Home'
      'Second Home'
    when 'PrimaryResidence','Primary'
      'Primary'
    when 'Investor','Investment'
      'Investment'
    else
      nil
    end
  end

  def self.number_of_units(key)
    case key
    when 1..4
      key
    else
      nil
    end
  end

  def self.purpose_of_refinance(key)
    case key
    when 'CashOutDebtConsolidation','Cash-Out/Debt Consolidation'
      'Cash-Out/Debt Consolidation'
    when 'CashOutHomeImprovement','Cash-Out/Home Improvement'
      'Cash-Out/Home Improvement'
    when 'CashOutOther','Cash-Out/Other'
      'Cash-Out/Other'
    when 'CashOutLimited','Limited Cash-Out'
      'Limited Cash-Out'
    when 'NoCashOutStreamlinedRefinance', 'ChangeInRateTerm', 'NoCashOutFHAStreamlinedRefinance', 'VAStreamlinedRefinance','No Cash-Out Rate/Term'
      'No Cash-Out Rate/Term'
    else
      nil
    end
  end

end
