class Delivery::FnmaPoolsV2Controller < Delivery::DeliveryController
  helper :xml

  before_filter ->{ prepend_view_path "app/views/delivery/fnma_pools_v2" }

  def loan_model 
    Smds::FnmaLoan
  end

  def delivery_model
    #todo:  might need an fnma_v2 pool method so that the loans from it 
    #get returned as (new) Smds::FnmaLoanV2
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
end
