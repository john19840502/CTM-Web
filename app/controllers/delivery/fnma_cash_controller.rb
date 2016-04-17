class Delivery::FnmaCashController < Delivery::DeliveryController
  helper :xml

  def initialize_delivery
    Smds::CashCommitment.create_all
  end

  def loan_model
    Smds::FnmaLoan
  end

  def delivery_model
    Smds::CashCommitment.fnma_only.includes(:compass_loan_details)
  end

  def delivery_summary_filename
    "fnma_commitments.xls"
  end

  def delivery_export_filename
    "#{@delivery.investor_commitment_number}.xml"
  end

  def delivery_export_mime_type
    "application/xml"
  end

  def delivery_export_type
    :xml
  end

  def delivery_name
    "FNMA Cash Commitments"
  end

  def filter_by_date_path
    [:filter_by_date, :delivery, :fnma_cash_index]
  end

  def pool_data_columns
    data.column_list.sort - %w(id created_at updated_at) + %w(number_of_loans total_upb)
  end

  def loan_data_columns
    %w(pool_id loan_id issue_date_upb current_upb first_payment_date last_paid_installment_date curtailment)
  end

end
