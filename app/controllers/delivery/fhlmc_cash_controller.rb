class Delivery::FhlmcCashController < Delivery::DeliveryController
  helper 'xml'
  before_filter :auth_me

  def auth_me
    redirect_to root_url, flash: { error: 'You are not authorized to view this resource' } unless can?(:manage, Smds::FhlmcLoan)
  end

  def prepend_view_paths
    prepend_view_path 'app/views/delivery'
    prepend_view_path 'app/views/delivery/fhlmc_shared'
  end

  def loan_model
    Smds::FhlmcLoan
  end

  def initialize_delivery
    create_all
  end

  def delivery_model
    Smds::CashCommitment.fhlmc_only.includes(:compass_loan_details)
  end

  def delivery_summary_filename
    "fhlmc_cash.xls"
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
    "FHLMC Cash"
  end

  def filter_by_date_path
    [:filter_by_date, :delivery, :fhlmc_pools]
  end

  def pool_data_columns
    %w(certified_on exported_at exported_by investor_commitment_number settlement_date number_of_loans total_upb  )
  end

  def loan_data_columns
    %w(pool_id loan_id issue_date_upb first_payment_date last_paid_installment_date curtailment )
  end

  def delivery_export_type
    'xml'
  end

  private

  def create_all
    existing_commitments = Smds::CashCommitment.pluck(:investor_commitment_number)
    commitments_to_create = all_commitment_numbers - existing_commitments
    commitments_to_create.each do |number|
      date = Smds::CompassLoanDetail.where(investor_commitment_number: number).pluck(:settlement_date).first
      Smds::CashCommitment.create(investor_commitment_number: number, settlement_date: date)
    end
  end

  def all_commitment_numbers
    Smds::CompassLoanDetail.pluck(:investor_commitment_number).
      compact.uniq.keep_if{|number| number.starts_with?('FD')}
  end

end
