class Delivery::FhlbPoolsController < Delivery::DeliveryController
  helper :xml

  def export_pre_uldd
    prepare_pre_fhlb_pool
    headers['Content-Type'] = "#{delivery_export_mime_type}"
    headers['Content-Disposition'] = "attachment; filename='Pre-FHLB ULDD #{Date.today}.xml'"
    headers['Cache-Control'] = ''
    render template: "fhlb_pools/export", :formats => [:xml]
  end
  
  def export_pre_csv
    prepare_pre_fhlb_pool
    headers['Content-Type'] = "text/csv"
    headers['Content-Disposition'] = "attachment; filename='Pre-FHLB CSV #{Date.today}.csv'"
    headers['Cache-Control'] = ''
 
    render text: Smds::FhlbCsvBuilder.new.make_csv(@loans)
  end


  def export_fhlb_csv
    pool = Smds::Pool.find(params[:record_id])
    headers['Content-Type'] = "text/csv"
    headers['Content-Disposition'] = "attachment; filename='#{pool.investor_commitment_number}.csv'"
    headers['Cache-Control'] = ''
 
    render text: Smds::FhlbCsvBuilder.new.make_csv(pool.fhlb_loans)
  end

  def initialize_delivery
    create_pools
  end

  def loan_model 
    Smds::FhlbLoan
  end

  def delivery_model
    Smds::Pool.fhlb.includes(:compass_loan_details)
  end

  def delivery_summary_filename
    "fhlb_pools.xls"
  end

  def delivery_export_filename
    "#{@delivery.investor_commitment_number}.xml"
  end

  def delivery_export_mime_type
    "application/xml"
  end

  def loan_test
    loan_num = params[:loan_num]
    @loan = loan_model.where(SellerLoanIdentifier: loan_num).first

    if @loan
      render file: "delivery/loan_test", :formats => [:xml], :locals=> {:loan => @loan}
    else
      text = "Could not find FNMA loan with loan_num #{params[:loan_num]}"
      render text: text, :content_type => Mime::TEXT
    end
  end

  def delivery_export_type
    :xml
  end

  def delivery_name
    "FHLB Pools"
  end

  def filter_by_date_path
    [:filter_by_date, :delivery, :fhlb_pools]
  end

  def pool_data_columns
    data.column_list.sort - %w(id created_at updated_at) + %w(number_of_loans total_upb)
  end

  def loan_data_columns
    %w(pool_id loan_id issue_date_upb current_upb first_payment_date last_paid_installment_date curtailment)
  end
  
  private

  def create_pools
    all_pools = Smds::CompassLoanDetail.pluck(:investor_commitment_number)\
      .compact.uniq.keep_if{|icn| icn.starts_with?('FH')}
    existing_pools = Smds::Pool.fhlb.pluck(:investor_commitment_number)
    pools_to_create = all_pools - existing_pools
    pools_to_create.each do |pool|
      detail = Smds::CompassLoanDetail.find_by_investor_commitment_number(pool)
      Smds::Pool.create!({:investor_commitment_number => pool,
                          prefix: 'FH',
                          settlement_date: detail.settlement_date,
                          pool_issue_date: detail.pool_issue_date}, without_protection: true)
    end
  end

  def fetch_custom_pool_loans
    nums = Smds::PreUlddLoan.pluck(:LnNbr)
    Array(Smds::FhlbLoan.find(nums))
  end

  def prepare_pre_fhlb_pool
    @delivery = Smds::Pool.new.tap do |pool|
      pool.investor_commitment_number = "FH0000000"
      pool.prefix = 'FH'
    end
    @loan_numbers = params[:loan_numbers]
    @loans = fetch_custom_pool_loans
  end

end
