class Delivery::FhlmcPoolsController < Delivery::DeliveryController
  helper :xml

  before_filter :auth_me

  def auth_me
    redirect_to root_url, flash: { error: 'You are not authorized to view this resource' } unless can?(:manage, Smds::FhlmcLoan)
  end

  def prepend_view_paths
    prepend_view_path 'app/views/delivery'
    prepend_view_path 'app/views/delivery/fhlmc_shared'
  end

  def initialize_delivery
    create_pools
  end

  def loan_model
    Smds::FhlmcLoan
  end

  def delivery_model
    Smds::Pool.fhlmc.includes(:compass_loan_details)
  end

  def delivery_summary_filename
    "fhlmc_pools.xls"
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
    "FHLMC Pools"
  end

  def filter_by_date_path
    [:filter_by_date, :delivery, :fhlmc_pools]
  end

  def pool_data_columns
    %w(certification_date assumability_indicator exported_at exported_by investor_commitment_number settlement_date number_of_loans total_upb  )
  end

  def loan_data_columns
    %w(pool_id loan_id issue_date_upb first_payment_date last_paid_installment_date curtailment )
  end



  private

  def create_pools
    all_pools = Smds::CompassLoanDetail.pluck(:investor_commitment_number)\
      .compact.uniq.keep_if{|icn| icn.starts_with?('MC')}
    existing_pools = Smds::Pool.fhlmc.pluck(:investor_commitment_number)
    pools_to_create = all_pools - existing_pools
    pools_to_create.each do |pool|
      detail = Smds::CompassLoanDetail.find_by_investor_commitment_number(pool)
      Smds::Pool.create!({:investor_commitment_number => pool,
                          prefix: 'MC',
                          settlement_date: detail.settlement_date,
                          pool_issue_date: detail.pool_issue_date}, without_protection: true)
    end
  end


end
