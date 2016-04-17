# Create UW Checklist Elements

puts 'Populating UW Checklists...'

section = UwchecklistSection.create(:name => 'All Loans', :page => 1, :is_display_for_all_loans => true)

UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Initial Signed 1003")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "*Validate Gov't Monitoring tab in Avista to the initial 1003*")

UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Homeowners Insurance
* <90 days to expiration- (evid. Renewal pd.)
* Sufficient coverage (Replacement/ Loan amt)
* Mortgagee=Cole Taylor Bank (NOT on Reimbursement)")

UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Title: Vesting, mortgagee, policy Amt and liens (Mortgagee will NOT be CTB on Reimbursement)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "24 month chain of title")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Insured Closing Letter")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Flood cert and proof of insurance if applicable")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Mortgage Insurance ________%")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Maximum rate______________ ")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Approval Expires_________________")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Doc Expire_____________")


section = UwchecklistSection.create(:name => 'Verifications for Initial Decision and Clear to Close', :page => 1, :is_display_for_all_loans => true,  :body => 
"||_. Initial|_. CTC|
|Assigned loan to self?|Y / N||
|Completed UW Sub. Screen|Y / N||
|Was 2075 used.  Obtain disc|Y / N|Y / N|
|Does Lock match UW?|Y / N|Y / N|
|Resubmitted to AUS?|Y / N|Y / N|
|Debt & ratios correct on AUS?|Y / N|Y / N|
|Property Type and Class 1008?|Y / N|Y / N|
|Final 1008 and AUS imaged?|Y / N|Y / N|
|Condo/PUD Unit #|Y / N|Y / N|
|Investor Guidelines Screen?|Y / N|Y / N|
|Income Calculations|Y / N|Y / N|
|Clear GSA/LDP|Y / N|Y / N|
|MI On TIL?|Y / N||
")


section = UwchecklistSection.create(:name => 'Property', :page => 2, :column => 1)
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Condo Documents")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Condo/PUD endorsement to title")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Complete Appraisal")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Condo/PUD Rider")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "PIW Disclosure")


section = UwchecklistSection.create(:name => 'Purchases', :page => 2, :column => 1, :loan_purpose_display_conditions => 'Purchase')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Purchase Agreement")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "HUD-1 evidencing _________________")


section = UwchecklistSection.create(:name => "DU Refi Plus\n(Min scores:  Primary: 620, INV/2nd 680)", :page => 2, :column => 1, :loan_purpose_display_conditions => 'RefiPlus')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Net Tangible Benefit")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "W-2")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "DU Refi Plus Certification")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Original Note/ Cred Supp verifying Borrowers")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Max cash back $250 (effective on apps after 7/1)")


section = UwchecklistSection.create(:name => "Refi's", :page => 2, :column => 1, :loan_purpose_display_conditions => 'Refinance')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Copy of subordination agreement")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Copy of Note for subordinate financing")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "3 day right of recession")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "No subordination financing")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Cash out not to exceed 2% or $2000.")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Spousal waiver/ Non Borrowing Titleholder")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Pay off Statements (no late fees, 59 days)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Pay off debts:________________________")



section = UwchecklistSection.create(:name => 'Federal', :page => 2, :column => 1)
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "GFE")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "TIL")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Settlement Services Provider List")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "ECOA Disclosure (Whls)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "ARM Disclosure (Whls ARMs only)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Appraisal Report and Delivery")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "4506T (Signature Req'd)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Cert and Authorization (Signature Req'd)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Customer Identification Verif. (Signature Req'd)")

section = UwchecklistSection.create(:name => 'FHA', :page => 2, :column => 1, :loan_program_display_conditions => 'FHA')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Appraisal Logging Successful")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Appraisal- FHA eligible comments")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Successful Case # Assignment")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Complete & Image Cond. Commitment")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "92900 signed by LO and Borrower")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "92900 enter ZFHA and Case ID")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Transmittal- add comments & sign")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Well & Septic (FHA/VA)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Arms Length")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Amend clause signed/dated at purch. agree.")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Verify FHA License")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "For Your Protection Get a Home Inspect. (Purch)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Important Notice to Homebuyers (Purch)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Borrower's contract w/ respect to hotel/ transient")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'none', :value => "(>1 unit owner occ or all investment)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Amendatory Clause/ Real Estate Cert. (Purch)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Notice to Homeowner:  Assumption of HUD/FHA")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "HUD Appraised Value Disclosure")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Informed Consumer Choice Disclosure")


section = UwchecklistSection.create(:name => 'VA', :page => 2, :column => 1, :loan_program_display_conditions => 'VA')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Amendatory Clause/ Real Estate Cert. (Purch if sales contract signed prior to VA notice of value)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Certification by Outside Lenders Processing Vendee Loans - Purc of VA foreclosed home")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "HUD/VA Addendum to Uniform Residential Loan Application (9200)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Counseling Checklist for Military Homebuyers (VA 26-0592) (active military only)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Federal Collection Policy Notice - refinance")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Request for a Certificate of Eligibility (VA 26-1880)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Request for Determination of Reasonable Value (not on IRRL)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "VA Interest Rate Reduction Refinancing Loan Worksheet (VA 26-8923) (VA to VA refi)- UW TO COMPLETE")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "VA Loan Comparison (IRRL)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Verification of VA Benefits (VA 26-8937) (Branch to submit to VA)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'none', :value => "**Note:  In Avista on VA app addendum UW must manually check the box regarding previous VA loans")

section = UwchecklistSection.create(:name => 'USDA', :page => 2, :column => 1, :loan_program_display_conditions => 'USDA')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "1980-21 executed by borrower (must have for submission to USDA)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Notice to Applicant income and household member's disc (signed by borrowers)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Verify that property address is eligible (on GUS feedback or at http://eligibility.sc.egov.usda.gov")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Verify that borrower meets income eligibility limits (on GUS feedback or at http://eligibility.sc.egov.usda.gov)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Verify appraiser states HUD guide 4905.1 and 4150.2 are met")


section = UwchecklistSection.create(:name => 'Colorado', :page => 2, :column => 2, :state_display_conditions => 'CO')

UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "CO Lock In Disclosure (all loans - required at lock/relock, extension, APR change of  >= .125% )")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "CO Tangible Net Benefit Disclosure (all loans)")

section = UwchecklistSection.create(:name => 'Georgia', :page => 2, :column => 2, :state_display_conditions => 'GA')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Tangible Benefit Worksheet  (Primary Refis)")

section = UwchecklistSection.create(:name => 'Illinois', :page => 2, :column => 2, :state_display_conditions => 'IL')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "ATC Condition -Predatory Lending DB - Cook, Will, Kane and Peoria County (July 1st)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Tangible Benefit Worksheet  (Primary Refis)")

section = UwchecklistSection.create(:name => 'New Jersey', :page => 2, :column => 2, :state_display_conditions => 'NJ')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "ATC condition- Please add NJ condition if private Well on a purchase")

section = UwchecklistSection.create(:name => 'New York', :page => 2, :column => 2, :state_display_conditions => 'NY')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Tangible Benefit Worksheet (Primary Refis)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Preclosing Pkg - Commitment Letter")

section = UwchecklistSection.create(:name => 'North Carolina', :page => 2, :column => 2, :state_display_conditions => 'NC')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Preclosing Pkg - Choice of Attorney (UW to issue)")

section = UwchecklistSection.create(:name => 'Ohio', :page => 2, :column => 2, :state_display_conditions => 'OH')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Net Tangible Benefit (primary refis)")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Verification of assets is req even if not on AUS.  Investor requirement")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "PTF condition purchases- Please add OH specific PTF condition from spreadsheet. Escrow disclosure")

section = UwchecklistSection.create(:name => 'Pennsylvania', :page => 2, :column => 2, :state_display_conditions => 'PA')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Tangible Benefit Worksheet  (Primary Refis)")

section = UwchecklistSection.create(:name => 'South Carolina', :page => 2, :column => 2, :state_display_conditions => 'TN')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Completed Attorney/Insurance Preference Checklist - PTC condition")

section = UwchecklistSection.create(:name => 'Tennessee', :page => 2, :column => 2, :state_display_conditions => 'TN')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Net Tangible Benefit Worksheet (primary Refis)")

section = UwchecklistSection.create(:name => 'Texas', :page => 2, :column => 2, :state_display_conditions => 'TX')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Texas Cash Out 12 Day Notice")

section = UwchecklistSection.create(:name => 'Wisconsin', :page => 2, :column => 2, :state_display_conditions => 'WI')
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "ATC Condition -Use WI condition on file from spreadsheet.  Use on all loans that have escrows.")

section = UwchecklistSection.create(:name => 'Eligible For Investors', :page => 2, :column => 2)
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Wells Fargo")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Sun Trust")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "GMAC")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "US Bank")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Fannie Mae")
UwchecklistItem.create(:uwchecklist_section => section, :bullet_type => 'check', :value => "Freddie Mac")

# Balance the checklist columns
UwchecklistSection.balance_columns
