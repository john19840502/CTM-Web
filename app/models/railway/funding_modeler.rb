class FundingModeler <  DatabaseRailway
  # attr_accessible :admin_fee, :appraisal_fee, :discount_fee, :escrow, :flood_cert, :fund_lock, :interim_interest, :loan_amount, :los_wire, :mortgage_insurance, :origination_fee, :wire_amt, :wire_diff

  belongs_to :loan

  def update_from_params(params)
    if !self.fund_lock
      self.wire_amt = params[:wire_amt]
      # self.wire_diff = params[:diff]
      self.admin_fee = params[:fund_admin_fee]
      self.ny_mtg_tax = params[:ny_mtg_tax]
      self.loan_amount = params[:loan_amount]
      self.lender_credit = params[:lender_credit]
      self.premium_price = params[:premium_price]
      self.broker_comp_lndr_pd = params[:broker_comp_lndr_pd]
      self.credit_to_cure = params[:credit_to_cure]
      self.mip_refund = params[:mip_refund]
      self.ctm_admin_whls = params[:ctm_admin_whls]
      self.credit_report = params[:credit_report]
      self.va_fund_fee = params[:va_fund_fee]
      self.grma_fee = params[:grma_fee]
      self.escrow_holdback = params[:escrow_holdback]
      self.principal_reduction = params[:principal_reduction]
      self.user_comments = params[:user_comments]
      if self.user_comments_changed?
        self.modeler_date_time = "#{Time.now.strftime('%m/%d/%Y %r')}" unless self.user_comments.blank?
        self.modeler_user = "#{current_user.display_name}" unless self.user_comments.blank?
      end
      self.origination_fee = params[:origination]
      self.appraisal_fee = params[:appraisal_credit]

    end

    if params[:f_toggle_lock].present?
      toggle_lock
    end

    self.save
  end

  def toggle_lock
    self.fund_lock = !self.fund_lock 
  end
  
end
