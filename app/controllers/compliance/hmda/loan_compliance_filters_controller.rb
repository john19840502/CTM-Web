class Compliance::Hmda::LoanComplianceFiltersController < ApplicationController

  def index
    lf = LoanComplianceFilter.find(params[:filter_number])
    @title = lf.filter_title
    @filter_num = params[:filter_number]
    @non_reportable = LoanComplianceFilter.find("15").filter_query(session[:range], session[:report_type])
    recs = lf.filter_query(session[:range], session[:report_type])
    data.model = recs.class.eql?(Array) && recs.empty? ? LoanComplianceEvent.none : recs
    data.columns = filter_default_columns + lf.filter_columns
    data.data_class = LoanComplianceEvent
    data.default_order = "aplnno"

    respond_to do |format|
      format.html
      format.json { render json: data.as_json(params) }
      format.xls { send_data data.to_xls }
    end
  end

  def remove_event
    begin
      LoanComplianceEvent.where(aplnno: params[:loan_num]).first.mark_unreportable
      flash[:warning] = "Aplnno #{params[:loan_num]} was successfully marked non-reportable."
      redirect_to :back
    rescue => e
      flash[:error] = e.message.split('~')
      redirect_to :back
    end
  end
    
  def filter_default_columns
    %w(aplnno reportable actdate)
  end

end
