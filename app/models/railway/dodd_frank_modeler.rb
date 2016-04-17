class DoddFrankModeler <  DatabaseRailway
  belongs_to  :loan
  has_many    :dodd_frank_modeler_misc_other_fees

  def update_from_params(params)
    fd_was_locked = self.fd_lock
    if !fd_was_locked
      self.loan_discount = params[:loan_discount]
      self.third_pt_proc_fee = params[:third_pt_proc_fee]
      self.origination_fee = params[:origination_fee]
      self.admin_fee = params[:admin_fee]
      self.principal_reduction_fee = params[:principal_reduction_fee]
      self.hoi_premium = params[:hoi_premium]
      self.taxes_due = params[:taxes_due]
      self.prorated_taxes = params[:prorated_taxes]
      self.premium_pricing = params[:premium_pricing]
      self.closing_cost = params[:closing_cost]
      self.difference = params[:difference]
      self.message = params[:message]
      # self.misc_other_fees = params[:misc_other_fees]
      # self.admin_fee = params[:admin_fee]
      self.user_comments = params[:user_comments]
      if self.user_comments_changed?
        self.modeler_date_time = "#{Time.now.strftime('%m/%d/%Y %r')}" unless self.user_comments.blank?
        self.modeler_user = "#{current_user.display_name}" unless self.user_comments.blank?
      end
      self.appraisal_fee = params[:appraisal]
      self.credit_report = params[:credit_report]
      self.flood_cert = params[:flood_cert]
      self.interim_interest = params[:interim_interest]
      self.mortgage_insurance_premium = params[:mortgage_insurance_premium]
      self.escrow = params[:escrows]
      self.title_fees = params[:title_fees]
      self.owner_policy = params[:owner_policy]
      self.recording_fees = params[:recording_fees]
      self.transfer_taxes = params[:transfer_taxes]
      self.credit_amount = params[:credit_amount]
      self.credit_amount_description = params[:credit_amount_description]
    end

    if params[:toggle_lock].present?
      toggle_lock
    end

    self.save

    unless fd_was_locked
      fees = params[:misc_other_fees] || []
      fees.each do |fee_data|
        id = fee_data[:id]
        fee = id.present? ? DoddFrankModelerMiscOtherFee.find(id) : DoddFrankModelerMiscOtherFee.new
        fee.dodd_frank_modeler_id = self.id
        fee.description = fee_data[:description]
        fee.amount = fee_data[:amount]
        fee.save!
      end
    end
  end

  def toggle_lock
    self.fd_lock = !self.fd_lock
  end

end
