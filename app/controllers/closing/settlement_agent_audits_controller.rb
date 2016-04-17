class Closing::SettlementAgentAuditsController < RestrictedAccessController

  def last_audit
    @loan = Loan.find_by_loan_num(params[:id]) || TestLoan.find_by_loan_num(params[:id])
    
    @last_audit = Closing::SettlementAgent::GetLastAudit.call @loan
    @conclusion = Closing::SettlementAgent::GetLastAudit.conclusion @loan, @last_audit

    respond_to do |format|
      format.json { render :json => { audit: @last_audit, trid_loan: @loan.trid_loan?, loan_type: @loan.try(:loan_purpose).try(:loan_type), conclusion: @conclusion} }
    end

  rescue => e
    handle_json_error_response e
  end

  def create
    audit_params = params.delete(:id)
    if current_user.roles.include?('suspense') ||  current_user.roles.include?('suspense_employee')
      params[:audited_by_suspense] = current_user.uuid
    else  
      params[:audited_by] = current_user.uuid
    end
    if params[:trid_loan] == true
      @settlement_agent_audit = SettlementAgentTridAudit.create(settlement_agent_trid_params, without_protection: true)
    else
      @settlement_agent_audit =  SettlementAgentAudit.create(settlement_agent_params, without_protection: true) 
    end
    @loan = @settlement_agent_audit.loan
    @conclusion = Closing::SettlementAgent::GetLastAudit.conclusion @loan, @settlement_agent_audit
    respond_to do |format|
      if @settlement_agent_audit.valid?
        format.json {render :json => { audit: @settlement_agent_audit, conclusion: @conclusion}}
      else
        format.json {render :json => { error: 'Could not save the audit.', success: false, "errors" => @settlement_agent_audit.errors.full_messages}, status: :not_acceptable }
      end
    end
  end

  def reports
    @start_date = Date.today.beginning_of_month - 1.month
    @end_date = Date.today.beginning_of_month - 1.day

    if !params[:start_date].in?(['null', nil]) && !params[:end_date].in?(['null', nil])
      @start_date = params[:start_date].to_date 
      @end_date = params[:end_date].to_date 
    end
    @monthly_audits = Closing::SettlementAgent::ReportData.monthly_audits(@start_date.to_date, @end_date.to_date, {params: params})
  end

  def comparision_report
    @year = params[:year].in?(["null", "undefined", nil]) ? Date.current.year : params[:year].to_i
    @comparision_report = Closing::SettlementAgent::ReportData.get_month_to_month_comparison(@year)
  end

  def is_closing_lead
    @is_lead = current_user.roles.include?('closing_leads')
    respond_to do |format|
      format.json { render :json => @is_lead.as_json }
    end
  end

  private

  def settlement_agent_params
    params.permit(:loan_id, :settlement_agent, :escrow_agent_id, :agent_page1_occurance, :agent_page2_occurance, :agent_page3_occurance, :agent_page1_count, :agent_page2_count, :agent_page3_count, :address_completed, :address_completed_occurance, :all_boxes_completed, :all_boxes_completed_occurance, :sectionb_page1_completed, :sectionb_page1_completed_occurance, :tolerance_cure_necessary, :tolerance_cure_necessary_occurance, :seller_concession_appear, :seller_concession_appear_occurance, :cash_from_borrower_match, :cash_from_borrower_match_occurance, :correct_fees_800section_credits, :correct_fees_800section_credits_occurance, :correct_fees_900section, :correct_fees_900section_occurance, :agent_charges_match_approved, :agent_charges_match_approved_occurance, :agent_show_correct_mbfees, :agent_show_correct_mbfees_occurance, :agent_changes_page2_hud_fees, :agent_changes_page2_hud_fees_occurance, :gfe_match_final_gfe, :gfe_match_final_gfe_occurance, :hud1_side_match_page2_hud, :hud1_side_match_page2_hud_occurance, :loan_terms_section_completed_acc, :loan_terms_section_completed_acc_occurance, :new_costs_cure_for_agent_completion, :new_costs_cure_for_agent_completion_occurance, :seller_credit_changed, :seller_credit_changed_occurance, :realtor_credit_changed, :realtor_credit_changed_occurance, :lender_credit_changed, :lender_credit_changed_occurance, :fee_increase, :fee_increase_occurance, :fee_decrease, :fee_decrease_occurance, :added_apr_fees, :added_apr_fees_occurance, :changed_closing_docs, :changed_closing_docs_occurance, :changed_legal_docs, :changed_legal_docs_occurance, :changed_power_of_attorney, :changed_power_of_attorney_occurance, :changed_doc_for_trust, :changed_doc_for_trust_occurance, :incorrectly_date_docs, :incorrectly_date_docs_occurance, :changed_closing_dates, :changed_closing_dates_occurance, :agent_executed_documents_correctly, :agent_executed_documents_correctly_occurance, :followed_closing_instructions, :followed_closing_instructions_occurance, :changed_nortc_correctly, :changed_nortc_correctly_occurance, :closing_conditions_been_met, :closing_conditions_been_met_occurance, :agent_sent_proper_doc_fundingauth, :agent_sent_proper_doc_fundingauth_occurance, :agent_disburse_loan_properdate, :agent_disburse_loan_properdate_occurance, :notification_pending_litigation, :notification_pending_litigation_occurance, :pay_off_liens, :pay_off_liens_occurance, :comments, :audited_by, :audited_by_suspense, :hud_review)
  end

  def settlement_agent_trid_params
    params.permit("loan_id", "settlement_agent", "escrow_agent_id", "cd_page1_correct", "cd_page1_correct_count", "agent_made_corrections_cd_page1", "agent_made_corrections_cd_page1_occurance", "cd_page2_correct", "cd_page2_correct_count", "correct_fees_showing_in_loan_cost_section_a", "correct_fees_showing_in_loan_cost_section_a_occurance", "correct_fees_showing_in_loan_cost_section_b", "correct_fees_showing_in_loan_cost_section_b_occurance", "correct_fees_showing_in_loan_cost_section_c", "correct_fees_showing_in_loan_cost_section_c_occurance", "correct_fees_showing_in_loan_cost_section_e", "correct_fees_showing_in_loan_cost_section_e_occurance", "correct_fees_showing_in_loan_cost_section_f", "correct_fees_showing_in_loan_cost_section_f_occurance", "correct_fees_showing_in_loan_cost_section_g", "correct_fees_showing_in_loan_cost_section_g_occurance", "correct_fees_showing_in_loan_cost_section_h", "correct_fees_showing_in_loan_cost_section_h_occurance", "all_lender_credits_showing_in_section_j", "all_lender_credits_showing_in_section_j_occurance", "cd_page3_correct", "cd_page3_correct_count", "cash_close_to_amended", "cash_close_to_amended_occurance", "due_from_borrower_closing_sectionk_amended", "due_from_borrower_closing_sectionk_amended_occurance", "paid_already_borrower_sectionl_amended", "paid_already_borrower_sectionl_amended_occurance", "cash_to_close_from_borrower_amdended", "cash_to_close_from_borrower_amdended_occurance", "seller_side_affect_borrower_side_of_page3", "seller_side_affect_borrower_side_of_page3_occurance", "payoffs_payments_closing_sectionk_amended", "payoffs_payments_closing_sectionk_amended_occurance", "cd_page4_correct", "cd_page4_correct_count", "settlement_agent_amend_loan_disclosure_on_page4", "settlement_agent_amend_loan_disclosure_on_page4_occurance", "cd_page5_correct", "cd_page5_correct_count", "settlement_agent_ament_loan_calculation_disclosure_info", "settlement_agent_ament_loan_calculation_disclosure_info_occurance", "applicable_parties_signed_page5", "applicable_parties_signed_page5_occurance", "cd_page6_correct", "cd_page6_correct_count", "settlement_agent_amend_additional_pages", "settlement_agent_amend_additional_pages_occurance", "agent_add_apr_fees_after_cd_approval", "agent_add_apr_fees_after_cd_approval_occurance", "agent_change_closing_documents_without_approval", "agent_change_closing_documents_without_approval_occurance", "agent_add_individuals_to_legal_docs", "agent_add_individuals_to_legal_docs_occurance", "agnet_amend_documents_to_use_power_of_attorney", "agnet_amend_documents_to_use_power_of_attorney_occurance", "agent_amend_documents_for_trust", "agent_amend_documents_for_trust_occurance", "agent_incorrectly_date_documents", "agent_incorrectly_date_documents_occurance", "agent_change_closing_dates_without_new_docs_approval", "agent_change_closing_dates_without_new_docs_approval_occurance", "settlement_agent_executed_documents_correctly", "settlement_agent_executed_documents_correctly_occurance", "agent_followed_our_specific_instructions", "agent_followed_our_specific_instructions_occurance", "agent_changed_nortc_correctly", "agent_changed_nortc_correctly_occurance", "all_closing_conditions_been_met", "all_closing_conditions_been_met_occurance", "settlement_agent_send_proper_docs_to_funding_auth_team", "settlement_agent_send_proper_docs_to_funding_auth_team_occurance", "settlement_agent_disburse_loan_on_proper_date", "settlement_agent_disburse_loan_on_proper_date_occurance", "did_we_receive_settlement_agent_closing_statement", "did_we_receive_settlement_agent_closing_statement_occurance", "any_difference_between_cd_and_settlement_agent_audit", "any_difference_between_cd_and_settlement_agent_audit_occurance", "settlement_agent_fund_loan_prior_to_lock_expiration", "settlement_agent_fund_loan_prior_to_lock_expiration_occurance", "did_we_extend_additional_days_on_lock", "did_we_extend_additional_days_on_lock_occurance", "have_we_received_notification_of_pending_litigation", "have_we_received_notification_of_pending_litigation_occurance", "did_agent_pay_off_liens_correctly", "did_agent_pay_off_liens_correctly_occurance", "comments", "hud_review", "qcount", "audited_by")
  end
end