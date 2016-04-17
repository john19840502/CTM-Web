class Delivery::FhlmcIndividualsController < Delivery::DeliveryController
  helper :xml

  before_filter :auth_me

  def auth_me
    redirect_to root_url, flash: { error: 'You are not authorized to view this resource' } unless can?(:manage, Smds::FhlmcLoan)
  end

  def index
  end

  def filter_by_loan
    @loan = Smds::FhlmcLoan.where(SellerLoanIdentifier: params[:loan_number]).first
    (redirect_to({ action: 'index' }, alert: "Cannot find FHLMC loan with loan number #{params[:loan_number]}") and return) unless @loan
    number = @loan.InvestorCommitNbr
    detail = Smds::CompassLoanDetail.find_by_investor_commitment_number(number)
    pool = Smds::Pool.where(:investor_commitment_number => number).first
    pool ||= Smds::Pool.create({:investor_commitment_number => number,
                        prefix: 'MC',
                        settlement_date: detail.settlement_date,
                        pool_issue_date: detail.pool_issue_date}, without_protection: true)
    data.label = "FHLMC Individuals"
    data.model = Smds::Pool.fhlmc.includes(:compass_loan_details)
    data.records = [pool]
    data.columns = filter_by_date_columns if filter_by_date_columns

    respond_to do |format|
      format.html
      format.xls { send_data data.to_xls, filename: filter_by_date_filename}
    end
  end

  def export
    @loans = Smds::FhlmcLoan.where(SellerLoanIdentifier: params[:record_id])
    @delivery = @loans.first.pool
    @delivery.originator(current_user)

    headers['Content-Type'] = "#{delivery_export_mime_type}"
    headers['Content-Disposition'] = "attachment; filename=#{delivery_export_filename}"
    headers['Cache-Control'] = ''
  end

  def prepend_view_paths
    prepend_view_path 'app/views/delivery'
    prepend_view_path 'app/views/delivery/fhlmc_shared'
  end

  def loan_model
    Smds::FhlmcLoan
  end

  def delivery_model
    Smds::Pool.fhlmc.includes(:compass_loan_details)
  end

  def delivery_summary_filename
    "fhlmc_individuals.xls"
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
      render_to_string(templete: 'delivery/loan_test', :formats => [:xml], :locals=> {:loan => @loan})
    else
      text = "Could not find FHLMC loan with loan_num #{params[:loan_num]}"
      render text: text, :content_type => Mime::TEXT
    end
  end

  def delivery_export_type
    :xml
  end

  def filter_by_loan_path
    [:filter_by_loan, :delivery, :fhlmc_individuals]
  end

  def pool_data_columns
    %w(certification_date assumability_indicator exported_at exported_by investor_commitment_number settlement_date number_of_loans total_upb  )
  end

  def loan_data_columns
    %w(pool_id loan_id issue_date_upb first_payment_date last_paid_installment_date curtailment )
  end
end
