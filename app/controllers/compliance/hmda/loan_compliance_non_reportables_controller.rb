class Compliance::Hmda::LoanComplianceNonReportablesController < ApplicationController

  def index
    @loans = search_loans

    respond_to do |format|
      format.html
      format.json { render json: data.as_json(params) }
    end
  end

  def search
    @loans = search_loans

    unless @start_dt.present?
      flash[:notice] = 'Please select either Year or Start/End date'
      return redirect_to(compliance_hmda_loan_compliance_non_reportables_path)
    end

    respond_to do |format|
      format.html { render 'index' }
      format.csv { send_data donwload_csv(@loans), filename: "hmda_non_reportable_loans_#{@start_dt.to_s}.csv" }
    end
  end

private
  def donwload_csv(loans)
    # column_names = ["loan_num", "full_name", "property_address", "pipeline_loan_status_description", "pipeline_lock_status_description", "excluded_from_hmda_on", "funded_at", "cancelled_or_withdrawn_at", "denied_at", "note"]
    column_names = ['Loan Number',
                    'Borrower Name',
                    'Property Street Address',
                    'Loan Status',
                    'Underwriting Status',
                    'Loan Cert Field: Does Prospective Applicant wish to Apply at this time?',
                    'Excluded from HMDA Date',
                    'Funded Date',
                    'Cancelled Date',
                    'Denied Date ',
                    'Loan Notes']
    CSV.generate do |csv|
      csv << column_names
      loans.each do |loan|
        csv << [ loan.loan_num,
          loan.try(:primary_borrower).try(:full_name),
          loan.property_address,
          loan.pipeline_lock_status_description,
          loan.pipeline_loan_status_description,
          loan.applicant_wishes_to_apply?,
          date_format(loan.excluded_from_hmda_on),
          date_format(loan.funded_at),
          date_format(loan.cancelled_or_withdrawn_at),
          date_format(loan.denied_at),
          loan.loan_notes_notes.order(:created_date).try(:last).try(:content)
        ]
      end
    end
  end

  def date_format dt
    return dt unless dt.present?
    dt.strftime('%m/%d/%Y')
  end

  def search_loans
    if params[:year].present?
      year = Date.new(params[:year].to_i, 1, 1)
      @start_dt = year.beginning_of_year
      end_dt = year.end_of_year
    elsif params[:start_date].present? && params[:end_date].present?
      @start_dt = params[:start_date]
      end_dt = params[:end_date]
    end

    if @start_dt
      @loans = Master::Loan.
        where('(funded_at BETWEEN ? and ?) or (denied_at BETWEEN ? and ?) or (cancelled_or_withdrawn_at BETWEEN ? and ?)', 
          @start_dt, end_dt, 
          @start_dt, end_dt, 
          @start_dt, end_dt)
    else
      @loans = []      
    end
    @loans
  end
end
