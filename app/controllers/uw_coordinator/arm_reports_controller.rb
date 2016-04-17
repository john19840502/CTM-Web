class UwCoordinator::ArmReportsController < RestrictedAccessController
  def index
    data.label   = 'Daily ARM report'
    data.model   = ArmReport
    data.columns = [
      :loan_num, 
      :last_name, 
      :channel, 
      :uw_product_code, 
      :ten_oh_three_product_name, 
      :pipeline_loan_status_description, 
      :lock_expiration_date, 
      :first_cap_rate, 
      :subsequent_cap_rate, 
      :life_time_cap_rate, 
      :first_rate_adjustment_months, 
      :subsequent_rate_adjustment_months
    ]

    respond_to do |format|
      format.html
      format.xls { send_data data.to_xls }
    end
  end
end