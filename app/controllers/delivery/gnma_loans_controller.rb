class Delivery::GnmaLoansController < Delivery::DeliveryController

  def initialize_delivery
    Smds::GnmaPool.update_pools

  end

  def loan_model
    Smds::GnmaLoan
  end

  def delivery_model
    Smds::GnmaPool
  end

  def delivery_summary_filename
    "gnma_pools.xls"
  end

  def delivery_export_filename
    "#{@delivery.pool_number}.txt"
  end

  def delivery_export_mime_type
    "text/plain"
  end

  def delivery_export_type
    :txt
  end

  def delivery_name
    "GNMA Pools"
  end

  def filter_by_date_path
    [:filter_by_date, :delivery, :gnma_loans]
  end

  def pool_data_columns
    %w(pool_number gnma_pool_number issue_type pool_type issue_date settlement_date original_aggregate_amount security_rate low_rate high_rate method
       ginnie_payment_date ginnie_maturity_date unpaid_date term tax_id number_of_loans new_issuer lookback_period exported_by exported_at)
  end

  def loan_data_columns
    %w(pool_number loan_number case_number last_pay_date unscheduled_principal_curtailment interest_rate principal_and_interest
      original_principal_amount unpaid_principal_balance)
  end

  def export
    @delivery = delivery_model.find(params[:record_id])
    @loans = (@delivery.loans self).to_a
    @delivery.originator(current_user)

    pool_errors = Smds::GnmaRecordRenderer.check_for_errors(Smds::GnmaPool::FILE_SPEC, @delivery)
    loan_errors = Smds::GnmaRecordRenderer.check_for_errors(Smds::GnmaLoan::FILE_SPEC, @loans, [], ["M05","M06","M07","M08"])
    misc_errors = Smds::GnmaRecordRenderer.check_for_errors(Smds::GnmaPool::SUBSCRIBER_FILE_SPEC, @delivery)
    misc_errors << Smds::GnmaRecordRenderer.check_for_errors(Smds::GnmaPool::MASTER_AGREEMENT_FILE_SPEC, @delivery)

    err = ""
    err << "POOL ERRORS:\n" << pool_errors unless pool_errors.empty?
    err << "LOAN ERRORS:\n" << loan_errors unless loan_errors.empty?
    err << "MISC ERRORS:\n" << misc_errors unless misc_errors.empty?

    unless err.empty?
      flash[:error] = err
      redirect_to :back
    else
      headers['Content-Type'] = "#{delivery_export_mime_type}"
      headers['Content-Disposition'] = "attachment; filename='#{delivery_export_filename}'"
      headers['Cache-Control'] = ''
    end
  end


end
