class UwCoordinator::CondSubmittedNotReceivedController < RestrictedAccessController
    




  def index
    data.label = 'Conditions Submitted, Not Received'
    data.model = CondSubmittedNotReceived
    data.columns = [:channel, :purpose, :loan_num, :borrower_last_name,
                    :state, :underwriter_name, :pac_condition, :mortgage_type, :product_code, :product_desc, :uw_submitted_at]
    respond_to do |format|
      format.html
      format.xls { send_data data.to_xls }
    end
  end

end
