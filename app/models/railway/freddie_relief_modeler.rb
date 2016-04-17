class FreddieReliefModeler <  DatabaseRailway
  # attr_accessible :accrued_interest, :actual_amount_princ, :actual_loan_amount, :cash_to_borrower, :fredd_closing_cost, :fredd_lock, :max_actual_amount, :max_loan_amount, :payoff_amount, :princ_curt, :step_three, :upb, :upb_perc

  belongs_to :loan
  
  def update_from_params(params)
    if !self.fredd_lock
      self.upb = params[:upb]
      self.accrued_interest = params[:accrued_interest]
      self.payoff_amount = params[:payoff_amount]
      self.fredd_closing_cost = params[:fredd_closing_cost]
      self.upb_perc = params[:upb_perc]
      self.step_three = params[:step_three]
      self.max_loan_amount = params[:max_loan_amount]
      self.actual_loan_amount = params[:actual_loan_amount]
      self.max_actual_amount = params[:max_actual_amount]
      self.princ_curt = params[:princ_curt]
      self.actual_amount_princ = params[:actual_amount_princ]
      self.modeler_pass_or_fail = params[:modeler_pass_or_fail]
      self.princ_curt_fail = params[:princ_curt_fail]
      self.actual_amout_prin_fail = params[:actual_amount_princ_fail]
      self.cash_to_borrower = params[:cash_to_borrower]
      self.cash_to_borrower_fail = params[:cash_to_borrower_fail]
      self.user_comments = params[:user_comments]
      if self.user_comments_changed?
        self.modeler_date_time = "#{Time.now.strftime('%m/%d/%Y %r')}" unless self.user_comments.blank?
        self.modeler_user = "#{current_user.display_name}" unless self.user_comments.blank?
      end
    end

    if params[:fredd_toggle_lock].present?
      toggle_lock
    end

    self.save
  end

  def toggle_lock
    self.fredd_lock = !self.fredd_lock
  end
  
end
