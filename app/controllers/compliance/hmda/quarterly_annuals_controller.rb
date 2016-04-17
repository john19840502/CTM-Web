class Compliance::Hmda::QuarterlyAnnualsController < ApplicationController
  def index
    get_records data

    respond_to do |format|
      format.html
      format.json { render json: data.as_json(params) }
      format.xls { send_data data.to_xls }
    end
  end

  def search

    flash[:error] = 'Period and year must both be selected.' unless params[:period].present? && params[:period_year].present?
    get_records data

    respond_to do |format|
      format.html { render :index }
      format.json { render json: data.as_json(params) }
      format.xls { send_data data.to_xls }
    end
  end

  def transform

    LoanComplianceEvent.do_transformations session[:qa_range]
    flash[:success] = 'Transformations processed successfully.'
    redirect_to :back
    
  end

  private 

  def get_records data
    params[:period] ||= session[:period]
    params[:period_year] ||= session[:period_year]
    if params[:period_year].present? && params[:period].present? && params[:period].in?(%w(Q1 Q2 Q3 Q4))
      session[:report_type]     = 'q'
      session[:range]           = LoanComplianceEvent.set_session_period(params[:period], params[:period_year], session[:report_type])
      session[:period]          = params[:period]
      session[:period_year]     = params[:period_year]

      data.model                = LoanComplianceEvent.for_period(session[:range], session[:report_type]) 
      # session[:period]        = params[:period]
      # session[:period_year]   = params[:period_year]
    else
      data.model = LoanComplianceEvent.where('1=2')
    end    
  
    data.columns        = data.model.column_names - ['exception_history', 'changed_values'] 
    data.server_side    = true
    data.default_order  = "aplnno"
  end

end
