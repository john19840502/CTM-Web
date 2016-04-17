module LoanModeler
  extend ActiveSupport::Concern

  def origination_fee_modeler
    if wholesale || (fha and !dodd_frank_modeler.nil?)
      dodd_frank_modeler.try(:origination_fee) || 0.0
    else
      return hudline_pre_trid(801, 'Origination Fee') rescue nil unless trid_loan?
      hudline('Origination Fee') rescue nil
    end
  end

  def origination_fee_fund_modeler
    if wholesale
      funding_modeler.try(:origination_fee) || 0.0
    else
      return hudline_pre_trid(801, 'Origination Fee') rescue nil unless trid_loan?
      hudline('Origination Fee') rescue nil
    end
  end

  def mortgage_ins_modeler
    return hudline_pre_trid(902, 'Mortgage insurance premium') rescue nil unless trid_loan?
    hud_lines.hud.where{sys_fee_name.like "%Mortgage Insurance Premium"}.map(&:total_amt).compact.sum rescue nil
  end

  def discount_fee_modeler
    return hudline_pre_trid(802, 'Discount Fee') rescue nil unless trid_loan?
    hudline('Discount Points') rescue nil
  end

  def third_pt_proc_fee_modeler
    dodd_frank_modeler.third_pt_proc_fee if dodd_frank_modeler
  end

  def appraisal_fee_modeler
    if fha and !dodd_frank_modeler.nil?
      dodd_frank_modeler.try(:appraisal_fee) || 0.0
    else
      return hudline_pre_trid(804, 'Appraisal Fee') rescue nil unless trid_loan?
      fee = hudline("Reimbursement for Appraisal")
      return fee if fee > 0
      hudline('Appraisal Fee')
    end
  end

  def appraisal_fee_fund_modeler
    if wholesale
      funding_modeler.try(:appraisal_fee) || 0.0
    else
      return hudline_pre_trid(804, 'Appraisal Fee') rescue nil unless trid_loan?
      fee = hudline("Reimbursement for Appraisal")
      return fee if fee > 0
      hudline('Appraisal Fee')
    end
  end

  def credit_report_modeler
    if fha and !dodd_frank_modeler.nil?
      dodd_frank_modeler.try(:credit_report) || 0.0
    else
      return hudline_pre_trid(805, 'Credit Report') rescue nil unless trid_loan?
      fee = hudline("Reimbursement for Credit Report")
      return fee if fee > 0
      hud_lines.hud.with_category('ServicesYouCannotShopFor', [ 'Credit Report' ])
    end
  end

  def credit_report_fund_modeler
    if wholesale
      funding_modeler.try(:credit_report) || 0.0
    else
      return hudline_pre_trid(805, 'Credit Report') rescue nil unless trid_loan?
      fee = hudline("Reimbursement for Credit Report")
      return fee if fee > 0
      hud_lines.hud.with_category('ServicesYouCannotShopFor', [ 'Credit Report' ])
    end
  end

  def flood_cert_modeler
    if fha and !dodd_frank_modeler.nil?
      dodd_frank_modeler.try(:flood_cert) || 0.0
    else
      return hudline_pre_trid(807, 'Flood Certification') rescue nil unless trid_loan?
      hudline('Flood Determination Fee') rescue nil
    end
  end

  def interim_interest_modeler
    if fha and !dodd_frank_modeler.nil?
      dodd_frank_modeler.try(:interim_interest) || 0.0
    else
      return hudline_pre_trid(901, 'Interest') rescue nil unless trid_loan?
      # hud_lines.hud.with_category('Prepaids', [ 'Prepaid Interest' ])
      hudline('Prepaid Interest')
    end
  end

  def hoi_premium_modeler
    dodd_frank_modeler.hoi_premium if dodd_frank_modeler
  end

  def mortgage_insurance_premium_modeler
    return dodd_frank_modeler.mortgage_insurance_premium if dodd_frank_modeler
    mortgage_ins_modeler
  end

  def escrow_modeler
    if fha and !dodd_frank_modeler.nil?
      dodd_frank_modeler.try(:escrow) || 0.0
    else
      if trid_loan?
        hud_lines.hud.with_category_and_paid_by_fee('Prepaids',
                              [ 'Other Insurance',
                                'Flood Insurance Premium' ]) +
        hud_lines.hud.with_category_and_fee_name_start_with_and_paid_by_fee('InitialEscrowPaymentAtClosing', '') +
        hud_lines.hud.with_category_and_fee_name_start_with_and_paid_by_fee('', 'Aggregate Adjustment')
      else
        hud_lines.hud_map_value(1002..1010)
      end
    end
  end

  def taxes_due_modeler
    dodd_frank_modeler.taxes_due if dodd_frank_modeler
  end

  def title_fees_modeler
    if fha and !dodd_frank_modeler.nil?
      dodd_frank_modeler.try(:title_fees) || 0.0
    else
      if trid_loan?
        hud_lines.hud.with_category_and_fee_name_start_with_and_paid_by_fee('ServicesYouCanShopFor', 'Title %').to_f - hudline("Title - NY Sales Tax").to_f
      else
        hud_lines.hud_map_value(1109..1119) +
        hudline_pre_trid(1102, 'Settlement or closing fee') +
        hudline_pre_trid(1104, "Lender's title insurance") rescue nil
      end
    end
  end

  def owner_policy_modeler
    if fha and !dodd_frank_modeler.nil?
     dodd_frank_modeler.try(:owner_policy) || 0.0
    else
      return hudline_pre_trid(1103, "Owner's title insurance") rescue nil unless trid_loan?
      hudline("Title - Owner's Title Policy (optional)") rescue nil
    end
  end

  def recording_fees_modeler
    if fha and !dodd_frank_modeler.nil?
      dodd_frank_modeler.try(:recording_fees) || 0.0
    else
      if trid_loan?
        hud_lines.hud.with_category_and_paid_by_fee 'TaxesAndOtherGovernmentFees', RECORDING_FEE_NAMES
      else
        hud_lines.hud_ary_value([1202], %w(Mortgage Releases Deed))
      end
    end
  end

  def transfer_taxes_modeler
    if fha and !dodd_frank_modeler.nil?
      dodd_frank_modeler.try(:transfer_taxes) || 0.0
    else
      if trid_loan?
        hud_lines.hud.with_category_and_paid_by_fee 'TaxesAndOtherGovernmentFees', TRANSFER_TAX_NAMES
      else
        hud_lines.hud_ary_value(1204..1205, %w(Mortgage Deed))
      end
    end
  end

  def misc_fees_modeler(index, line_number)
    if fha and !dodd_frank_modeler.nil?
      dodd_frank_modeler.try("misc_fees_#{index}").to_f || 0.0
    elsif fha and dodd_frank_modeler.nil?
      return hudline_pre_trid(line_number, "") rescue nil unless trid_loan?
      hudline("") rescue 0
    else
      return hudline_pre_trid(line_number, "") rescue nil unless trid_loan?
      hudline("") rescue 0
    end
  end

  def misc_fee_name(index)
    dodd_frank_fee = "misc_fee_#{index}_name"
    dodd_frank_modeler.try(dodd_frank_fee.to_sym)
  end

  def prorated_taxes_modeler
    dodd_frank_modeler.prorated_taxes if dodd_frank_modeler
  end

  def premium_pricing_modeler
    if dodd_frank_modeler && dodd_frank_modeler.premium_pricing.present?
      dodd_frank_modeler.premium_pricing
    else
      return hudline_pre_trid(808, 'Premium Pricing') rescue nil unless trid_loan?
      hudline('Premium Pricing') rescue nil
    end
  end

  def closing_cost_modeler
    dodd_frank_modeler.closing_cost if dodd_frank_modeler
  end

  # def fees_paid_by_lender_modeler
  #   hud_lines.hud.where(paid_by: "Lender").map(&:total_amt).sum.to_f
  # end

  def lender_credit_modeler_df
    hudline "Lender Credit"
  end

  def cures_modeler
    hudline "Cures"
  end

  def fd_lock_modeler
    dodd_frank_modeler.fd_lock if dodd_frank_modeler
  end

  def difference_modeler
    dodd_frank_modeler.difference if dodd_frank_modeler
  end

  def message_modeler
    dodd_frank_modeler.message if dodd_frank_modeler
  end

  def misc_other_fees_modeler
    dodd_frank_modeler.misc_other_fees if dodd_frank_modeler
  end

  def dodd_frank_misc_other_fees
    dodd_frank_modeler.dodd_frank_modeler_misc_other_fees if dodd_frank_modeler
  end

  def loan_discount_modeler
    return dodd_frank_modeler.loan_discount if dodd_frank_modeler
    return hudline("Discount Points")
    nil
  end

  def total_ln_amt_modeler
    number_to_currency lock_loan_datum.try(:total_loan_amt)
  end

  def net_price_modeler
    lock_price.net_price.round(6) rescue nil
  end

  def final_note_rate_modeler
    lock_price.final_note_rate rescue nil
  end

  def los_wire_modeler
    calculations.where(name: "NetLoanDisbursementAmount").first.value rescue nil
  end

  def wire_amt_modeler
    funding_modeler.wire_amt if funding_modeler
  end

  def wire_diff_modeler
    # funding_modeler.wire_amt if funding_modeler
    los_wire_modeler.to_f - funding_modeler.wire_amt.scan(/[.\d]/).join().to_f if funding_modeler
  end

  def fund_lock_modeler
    funding_modeler.fund_lock if funding_modeler
  end

  def ny_mtg_tax_modeler
    return funding_modeler.ny_mtg_tax if funding_modeler
    return hudline("Title - NY Sales Tax")
    nil
  end

  def lender_credit_modeler
    funding_modeler.lender_credit if funding_modeler
  end

  def premium_price_modeler
    if self.funding_modeler.nil?
      return hudline('Premium Pricing') if trid_loan?
      hudline_pre_trid(808, 'Premium Pricing')
    else
      funding_modeler.premium_price
    end
  end

  def broker_comp_lndr_pd_modeler
    hud_lines.hud.where(paid_by: "Lender").map(&:total_amt).sum.to_f
  end

  def credit_to_cure_modeler
    funding_modeler.credit_to_cure if funding_modeler
  end

  def mip_refund_modeler
    return funding_modeler.mip_refund if funding_modeler
    return hud_lines.hud.hud_line_value_and_paid_by_fee("Administration Fee") if wholesale
    nil
  end

  def ctm_admin_whls_modeler
    funding_modeler.ctm_admin_whls if funding_modeler
  end

  def admin_fee_modeler
    hud_lines.hud.hud_line_value_and_paid_by_fee("Administration Fee")
  end

  def principal_reduction_fee_modeler
    return dodd_frank_modeler.principal_reduction_fee if dodd_frank_modeler
    hudline "Principal Reduction paid to MB Financial"
  end

  def va_fund_fee_modeler
    return funding_modeler.va_fund_fee if funding_modeler
    return hudline("VA funding fee")
    nil
  end

  def grma_fee_modeler
    return funding_modeler.grma_fee if funding_modeler
    return hud_lines.hud.hud_line_value_and_paid_by_fee("GRMA")
    nil
  end

  def escrow_holdback_modeler
    funding_modeler.escrow_holdback if funding_modeler
  end

  def principal_reduction_modeler
    if funding_modeler
      funding_modeler.principal_reduction
    else
      return hud_lines.by_hud_line(1303).last.try(:total_amt) unless trid_loan?
      hudline "Principal Reduction paid to MB Financial"
    end
  end

  def loan_amount_modeler
    lock_loan_datum.try(:total_loan_amt)
  end

  def upb_modeler
    freddie_relief_modeler.upb unless freddie_relief_modeler.nil?
  end

  def accrued_interest_modeler
    freddie_relief_modeler.accrued_interest unless freddie_relief_modeler.nil?
  end

  def payoff_amount_modeler
    freddie_relief_modeler.payoff_amount unless freddie_relief_modeler.nil?
  end

  def fredd_closing_cost_modeler
    freddie_relief_modeler.fredd_closing_cost unless freddie_relief_modeler.nil?
  end

  def upb_perc_modeler
    freddie_relief_modeler.upb_perc unless freddie_relief_modeler.nil?
  end

  def step_three_modeler
    freddie_relief_modeler.step_three unless freddie_relief_modeler.nil?
  end

  def max_loan_amount_modeler
    freddie_relief_modeler.max_loan_amount unless freddie_relief_modeler.nil?
  end

  def actual_loan_amount_modeler
    lock_loan_datum.try(:total_loan_amt)
  end

  def princ_curt_modeler
    freddie_relief_modeler.princ_curt unless freddie_relief_modeler.nil?
  end

  def max_actual_amount_modeler
    freddie_relief_modeler.max_actual_amount unless freddie_relief_modeler.nil?
  end

  def actual_amount_princ_modeler
    freddie_relief_modeler.actual_amount_princ unless freddie_relief_modeler.nil?
  end

  def cash_to_borrower_modeler
    freddie_relief_modeler.cash_to_borrower unless freddie_relief_modeler.nil?
  end

  def fredd_lock_modeler
    freddie_relief_modeler.fredd_lock unless freddie_relief_modeler.nil?
  end

  def upb_perc_fail
    freddie_relief_modeler.upb_perc_fail unless freddie_relief_modeler.nil?
  end

  def max_actual_amount_fail
    freddie_relief_modeler.max_actual_amount_fail unless freddie_relief_modeler.nil?
  end

  def princ_curt_fail
    freddie_relief_modeler.princ_curt_fail unless freddie_relief_modeler.nil?
  end

  def actual_amout_prin_fail
    freddie_relief_modeler.actual_amout_prin_fail unless freddie_relief_modeler.nil?
  end

  def cash_to_borrower_fail
    freddie_relief_modeler.cash_to_borrower_fail unless freddie_relief_modeler.nil?
  end

  def modeler_pass_or_fail
    freddie_relief_modeler.modeler_pass_or_fail unless freddie_relief_modeler.nil?
  end

  def broker_name_modeler
    "#{self.try(:account_info).try(:broker_first_name)}" + ' ' + "#{self.try(:account_info).try(:broker_last_name)}"
  end

  def broker_comp_tier_rate
    comp_tiers_from_view.last.try(:comp_tier).to_f
  end

  def max_broker_comp_modeler
    (loan_amount_modeler * (broker_comp_tier_rate / 100)).round(2) rescue nil
  end

  def total_broker_comp_gfe
    broker_comp_modeler.total_broker_comp_gfe unless broker_comp_modeler.nil?
  end

  def user_comments_dodd_frank
    dodd_frank_modeler.user_comments unless dodd_frank_modeler.nil?
  end

  def current_modeler_user
    if !user_comments_dodd_frank.blank?
      dodd_frank_modeler.modeler_user
    else
      ''
    end
  end

  def modeler_date_time
    if !user_comments_dodd_frank.blank?
      dodd_frank_modeler.modeler_date_time
    else
      ''
    end
  end

  def user_comments_freddie
    freddie_relief_modeler.user_comments unless freddie_relief_modeler.nil?
  end

  def current_modeler_user_freddie
    if !user_comments_freddie.blank?
      freddie_relief_modeler.modeler_user
    else
      ''
    end
  end

  def modeler_date_time_freddie
    if !user_comments_freddie.blank?
      freddie_relief_modeler.modeler_date_time
    else
      ''
    end
  end

  def user_comments_funding
    funding_modeler.user_comments unless funding_modeler.nil?
  end

  def current_modeler_user_funding
    if !user_comments_funding.blank?
      funding_modeler.modeler_user
    else
      ''
    end
  end

  def modeler_date_time_funding
    if !user_comments_funding.blank?
      funding_modeler.modeler_date_time
    else
      ''
    end
  end

  def user_comments_broker_comp
    broker_comp_modeler.user_comments unless broker_comp_modeler.nil?
  end

  def current_modeler_user_broker_comp
    if !user_comments_broker_comp.blank?
      broker_comp_modeler.modeler_user
    else
      ''
    end
  end

  def modeler_date_time_broker_comp
    if !user_comments_broker_comp.blank?
      broker_comp_modeler.modeler_date_time
    else
      ''
    end
  end

  def misc_fee_lines_modeler
    hud_lines.hud.where{
      (line_num.in Hash[LoanModeler::MISC_FEES].values) &
      (total_amt > 0)
    }.select([:total_amt, :user_def_fee_name])
  end

  RECORDING_FEE_NAMES = [ "Assignment Recording Fee",
                          "E-filing",
                          "MLC Recording Fee",
                          "Mortgage Recording Fee",
                          "Recording CEMA",
                          "Recording DPA",
                          "Recording Fees",
                          "Recording POA",
                          "RP5217 - NY",
                          "Subordination Recording Fee" ]

  MISC_FEES = [
    [1, 811],
    [2, 812],
    [3, 813],
    [4, 814],
    [5, 815],
    [6, 816],
    [7, 817],
    [8, 818],
    [9, 819],
    [10, 820],
    [11, 821],
    [12, 822],
    [13, 823],
    [14, 824],
    [15, 825],
    [16, 1206],
    [17, 1207],
    [18, 1208],
    [19, 1302],
    [20, 1303],
    [21, 1304],
    [22, 1305]
  ]

  TRANSFER_TAX_NAMES = ["24 Month Chain of title",
                        "Archive Fee",
                        "Assignment Endorsement Fee",
                        "Attorney's Fee",
                        "Bankruptcy search",
                        "Binder Fee",
                        "Borrower Attorney Fee",
                        "Chain of Title",
                        "Closing Protection Letter",
                        "Commitment Fee",
                        "Completion Escrow",
                        "Copy Fee",
                        "Courier Fee",
                        "Departmentals (NY)",
                        "Disbursement Fee",
                        "Doc Prep Fee",
                        "Document Signing Fee",
                        "E-Document Fee",
                        "E-Record Fee",
                        "Escrow Service Fee",
                        "FL Surcharge",
                        "Funding Fee",
                        "IL PLD",
                        "IL Policy Fee",
                        "Lender's Title Policy",
                        "Loan Tie-In Fee",
                        "Messenger Fee",
                        "MLC AKA Municipal Lien Certs",
                        "MLC Fee",
                        "MN Conservation",
                        "Mobile Notary",
                        "New Loan Services Fee",
                        "NJ Filed Notice of Settlement",
                        "NJ Recording Handling Fee",
                        "NJ Tidelands Search",
                        "NJ Upper Court Search",
                        "Notary Fee",
                        "NY Sales Tax",
                        "Overnight Delivery Fee",
                        "Patriot Search",
                        "Pest Inspection Fee",
                        "Processing Fee",
                        "Reconveyance Fee",
                        "Recording Service Fee",
                        "Releases Recording Fee",
                        "Rundown/Record Fee",
                        "Settlement Fee",
                        "Simultaneous Issue Fee",
                        "Special Assessment Letter",
                        "Sub-Escrow Fee",
                        "Survey Fee",
                        "Tax and Assessments Searches",
                        "Tax Certificate",
                        "Tax Service Fee",
                        "TIEFF",
                        "Title Abstract",
                        "Title Closer Fee",
                        "Title Endorsement Fee",
                        "Title Examination Fee",
                        "Title Insurance Binder fee",
                        "Title Pick Up Fee",
                        "Title Search",
                        "Transaction Mangement Fee",
                        "TX Policy Guarantee Fee",
                        "Wire Fee",
                        "Wire Transfer Fee"]


private
  def wholesale
    self.try(:account_info).try(:channel) == 'W0-Wholesale Standard'
  end

  def fha
    self.try(:mortgage_term).try(:mortgage_type) == 'FHA'
  end

  def hudline fee_name
    hud_lines.hud.hud_line_value fee_name
  end

  def hudline_pre_trid(num, fee_name)
    hud_lines.hud_line_value_pre_trid(num, fee_name)
  end

end
