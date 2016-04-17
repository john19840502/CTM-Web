class Registration::EsignConsentController < RestrictedAccessController

  helper :loan_denial

  def index
    set_default_form_values
    loans = loan_query
    @loans = Kaminari.paginate_array(loans).page(params[:page]).per(20)
  end

  def create
    save_params = clean_consent_params
    Rails.logger.debug "Saving ESign Constent for custom loan data #{save_params[:id]}"
    @custom_data = Master::LoanDetails::CustomLoanData.find(save_params[:id])
    @custom_data.consent_action = converted_consent_action(save_params)
    @custom_data.consent_complete = save_params[:consent_complete]
    if @custom_data.valid?
      @custom_data.save
      respond_to do |format|
        format.json
      end
    else
      respond_to do |format|
        format.json { render :json => { error: @custom_data.errors.full_messages, success: false }, status: :internal_server_error }
      end
    end
    rescue Exception => e
      Rails.logger.error ExceptionFormatter.new(e)
      render json: { error: e.message }, status: 500
  end

  def search
    set_default_form_values

    loans = []
    if !params[:loan_id].empty?
      loan_num = params[:loan_id]
      @loan_text = loan_num
      loan = Master::Loan.find_by(loan_num: loan_num)
      if loan.nil?
        @error = "No loan found for #{loan_num}"
      elsif loan.application_date.nil?
        @error = "Application date for loan #{loan_num} unknown"
      elsif  TRID_DATE.beginning_of_day > loan.application_date
        @error = "Loan #{loan_num} was applied for before the TRID cutover"
      elsif loan.denied_at.nil? && loan.cancelled_or_withdrawn_at.nil?
        @error = "Loan #{loan_num} was not Cancelled, Denied, or Withdrawn"
      elsif !loan.docmagic_disclosure_request_created?
        @error = "Loan #{loan_num} has not been disclosed"
      else
        loans << loan
      end
    else
      loans = loan_query(start_date(params), end_date(params))
    end
    @loans = Kaminari.paginate_array(loans).page(params[:page]).per(20)
    render "index"
  end

  private

  def set_default_form_values
    set_default_date_text
    set_default_loan_text
  end

  def set_default_loan_text
    @loan_text = "Loan number"
  end

  def set_default_date_text
    @start_date_text = "Start Date"
    @end_date_text = "End Date"
  end

  def completed_esign_ids
    Master::LoanDetails::CustomLoanData.completed_consent_ids.join(',')
  end

  def initial_disclosure_ran_ids
    GfeDetail.undisclosed.pluck(:loan_id)
  end

  def clean_consent_params
    params.slice(:id, :consent_action, :consent_complete)
  end

  def converted_consent_action params
    params[:consent_action].blank? ? nil : params[:consent_action]
  end

  def start_date params
    s = params[:start_date]
    date = s.empty? ? TRID_DATE : s.to_date
    date = TRID_DATE if TRID_DATE > date
    @start_date_text = date.strftime("%m/%d/%Y")
    date
  end

  def end_date params
    s = params[:end_date]
    date = s.empty? ? Date.today : s.to_date
    @end_date_text = date.strftime("%m/%d/%Y")
    date
  end

  def sorted loans
    loans.sort { |a,b| (a.application_date && b.application_date) ? 
          a.application_date <=> b.application_date : 
          (a ? 1 : -1) }
  end

  def loan_query start_date=nil, end_date=nil
    query = Master::Loan.trid_loans.
      where { ((denied_at != nil) | (cancelled_or_withdrawn_at != nil))}.
      joins{custom_loan_data.outer}.
      where{custom_loan_data.consent_complete == nil}

    if start_date && end_date
      query = query.where {
        (application_date >= start_date) &
        (application_date <= end_date)
      }
    end
    
    query.
      order('application_date ASC').
      select { |loan| loan.docmagic_disclosure_request_created? }
  end

end
