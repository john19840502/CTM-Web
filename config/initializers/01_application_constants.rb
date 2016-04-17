ORGANIZATION_NAME = 'Cole Taylor Capital Group'
APPLICATION_NAME  = 'CTM Web'

AUTHORIZATION_RULES_FILE = "#{Rails.root}/config/authorization_rules.rb"

# Should UW Checklists display all items?
FILTER_UWCHECKLIST_DISPLAY = true

TABLE_NAME_PREFIX = 'CTMWEB_'

#Finance Constants

# Changed per CTWEB-533. Shouldn't be used anymore
# but here just in case.
DEFAULT_GROSS_COMMISSION = 0

class LoanPipeline
  ACTIVE_PIPELINE =
  [
    'U/W Denied',
    'U/W Conditions Pending Review',
    'U/W Approved w/Conditions',
    'U/W Final Approval/Ready to Fund',
    'New',
    'Closed',
    'Docs Out',
    'U/W Final Approval/Ready for Docs',
    'U/W Suspended',
    'Submitted',
    'Imported',
    'Submit/Error',
    'Closing Request Received',
    'Funding Request Received',
    'U/W Submitted',
    'U/W Received',
    'U/W Exception Submitted',
    'Closing Cancelled/Postponed'
  ]

  INACTIVE_PIPELINE =
  [
    'Purchased',
    'Cancelled',
    'Withdrawn',
    'Servicing',
    'Shipped to Investor',
    'Shipping Received',
    'Investor Suspended',
    'Funded'
  ]

  LOAN_VALIDATION_STATUSES =
  [
    'U/W Received',
    'U/W Submitted',
    'U/W Final Approval/Ready for Docs',
    'Closing Request Received',
    'Closed'
  ]
end

# There are checks agains the actual values of these strings.
# If you are changing them, you must make sure it doesn't break anything
class UserProfile
  ACCOUNTING_TITLES =
    [
      'Loan Officer',
      'Processor',
      'Branch Manager / NON Storefront',
      'Branch Manager Storefront',
      'Branch Sales Manager'
    ]
end

PURPOSE_OF_REFINANCE_DICT = {
  'CashOutDebtConsolidation' => 'Cash-Out/Debt Consolidation',
  'CashOutHomeImprovement' => 'Cash-Out/Home Improvement',
  'CashOutOther' => 'Cash-Out/Other',
  'CashOutLimited' => 'Limited Cash-Out',
  'ChangeInRateTerm' => 'No Cash-Out Rate/Term'
}

class ValidationConfig
  LTV_80_PERCENT_WARNING_PRODUCT_CODES =
    ['C10/1ARM LIB HIBAL',
    'C15FXD',
    'C15FXD HIBAL',
    'C20FXD HIBAL',
    'C30FXD',
    'C30FXD HIBAL',
    'C5/1ARMLIB HIBAL',
    'C7/1ARM LIB',
    'C20FXD',
    'C7/1ARM LIB HIBAL',
    'J30FXD',
    'J5/1ARM LIBOR',
    'J15FXD',
    'J5/1ARM LIB',
    'J7/1 ARM LIB',
    'C20FXDFR',
    'C10/1ARM LIBOR',
    'C5/1ARM LIB',
    'C30FXD HIBAL',
    'DPAIN']
end
