class Delivery::FnmaLoansController < Delivery::DeliveryController
  helper :xml

  def using_fnma_v2?
    params[:use_fnma_v2] == "true"
  end

  def export
    if using_fnma_v2?
      redirect_to controller: "fnma_pools_v2", action: "export", format: :xml, record_id: params[:record_id]
      return
    end
    super
  end

  def initialize_delivery
    Smds::CompassLoanDetail.create_pools
  end

  def loan_model 
    Smds::FnmaLoan
  end

  def delivery_model
    Smds::Pool.fnma.includes(:compass_loan_details)
  end

  def delivery_summary_filename
    "fnma_pools.xls"
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
      render_to_string(template: "delivery/loan_test", :formats => [:xml], :locals=> {:loan => @loan})
    else
      text = "Could not find FNMA loan with loan_num #{params[:loan_num]}"
      render text: text, :content_type => Mime::TEXT
    end
  end

  def delivery_export_type
    :xml
  end

  def delivery_name
    "FNMA Pools"
  end

  def filter_by_date_path
    [:filter_by_date, :delivery, :fnma_loans]
  end

  def pool_data_columns
    data.column_list.sort - %w(id created_at updated_at) + %w(number_of_loans total_upb)
  end

  def loan_data_columns
    %w(pool_id loan_id issue_date_upb current_upb first_payment_date last_paid_installment_date curtailment)
  end
  
end
