# Explicitly require the cancan_bridge, which is the file where 
# as_action_aliases is defined.  Without this require, things sometimes
# get into a state where that file is not yet autoloaded and initialize()
# raises an error that as_action_aliases is undefined.  
require 'active_scaffold/bridges/cancan/cancan_bridge'

class Ability
  include CanCan::Ability

  def initialize(user)
    as_action_aliases
    user ||= User.new # guest user (not logged in)

    # can :manage, :foo

    if user.roles.include? 'fiserv_nightly_report'
      can :read, [ BoardingFile ]
    end

    if user.roles.include? 'servicing_admin'
      can :manage, [ BoardingFile ]
    end

    if user.roles.include? 'underwriter_manager'
      can :manage, [ BpmStatisticReport ]
    end

    if user.roles.include? 'loan_delivery'
      can :manage, [ Smds::Pool, Smds::CashCommitment, Smds::FhlmcLoan, Smds::FnmaLoan ]
    end

    if user.roles.include? 'admin'
      can :manage, :all
    else
      cannot :manage, [UsageStat]
      can :manage, :group #, [Group, Aktor, Role]
    end

    if user.roles.include? 'bpm'
        can :manage, :all
    else
        can :manage, :group #, [Group, Aktor, Role]
    end

    if user.roles.include? 'compliance'
      can :manage, [RegoReport, CtmExecs, LoanComplianceEvent]
    end

    if user.roles.include? 'hr'
      can :manage,  BRANCH_COMPENSATION_BLOCK

      can :read, CORE_BLOCK
    end

    if user.roles.include? 'accounting'
      can :manage, [BranchCommissionReport, AccountingScheduledFunding, ]
      can :read, BRANCH_COMPENSATION_BLOCK + CORE_BLOCK
    end

    if user.roles.include? 'risk_management'
      can :manage, [RegoReport]
      can :read, [CtmExecs]
    end

    if user.roles.include? 'sales'
      can :manage, [Region, AreaManagerRegion]
    end

    if user.roles.include? 'secondary'
      can :manage, [ CreditSuisseOpsReport, InvestorPricingImport, ]
    end

    if user.roles.include? 'servicing'
      can :manage, [RegoReport, CtmExecs, ]
    end

    if user.roles.include? 'closing'
      can :manage, [Loan]
    end

    if user.roles.include? 'lock_desk'
      can :manage, [CreditSuisseLockFile, CreditSuisseOpsReport]
    end

    if user.roles.include? 'pac'
      can :manage, [CreditSuisseAppraisalFile, CreditSuisseOpsReport]
    end

    if user.roles.include? 'underwriter'
      can :manage, [CreditSuisseAppraisalFile, CreditSuisseOpsReport, ProductGuideline, ProductGuidelineDoc, ProductDatum]
    end

    if user.roles.include? 'registration'
      can :manage, [Loan]
    end    

    if user.roles.include? 'preclosing'
      can :manage, [Loan]
    end

    if user.roles.include? 'post_closing'
      can :manage, [CreditSuisseFundingFile, CreditSuisseOpsReport]
    end

    if user.roles.include? 'title_vendor_admin'
      can :manage, [Vendor, StateTitleVendor]
    end

    # if user.roles.include? :normal_user
    #   can :manage,
    # end

    # default roles permissions

    can :manage, [Note, LoanNote, ]
Rails.logger.debug user.roles

  end

  private

  BRANCH_COMPENSATION_BLOCK = [DatamartUserCompensationPlan, BranchCompensation, BranchCompensationDetail, BranchEmployeeOtherCompensation, DatamartUserProfile, CommissionPlanDetail]

  CORE_BLOCK = [Institution, Loan, Master::Loan, BranchEmployee]
end

