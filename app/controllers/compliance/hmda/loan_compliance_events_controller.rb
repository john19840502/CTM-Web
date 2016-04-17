# Used require_or_load here b/c I was getting uninitialized
# constant on the *second* page load.  Just like this:
# http://stackoverflow.com/questions/2796465/first-call-to-a-controller-constant-is-defined-second-call-uninitialized-con
#  - Greg
require_or_load 'lar_file_importer'
require_or_load 'hmda_mass_update'

class Compliance::Hmda::LoanComplianceEventsController < ApplicationController

  def index
    data.model = LoanComplianceEvent.for_period(session[:range], session[:report_type])
    data.columns = data.model.column_names - ['exception_history', 'changed_values', 'updated_at']
    data.server_side = true
    data.default_order = "aplnno"
    data.table_id = 'loan_compliance_events'

    respond_to do |format|
      format.html
      format.json { render json: data.as_json(params.merge('iDisplayLength' => 5)) }
      format.xls { send_data data.to_xls }
    end
  end

  def import_form
    if params[:id].present?
      @job_status = LoanComplianceEventUpload.where(id: params[:id]).last.job_status
    end

    if (loans = LoanComplianceEvent.unexported_for_period(session[:range], session[:report_type])).any?
      @loan_upload = loans.last.loan_compliance_event_upload
      render "append_form"
    else
      render "import_form"
    end
  end

  def set_session
    period = params[:q_period] || params[:m_period]
    year = params[:period_year]

    if period.present? && year.present?
      session[:report_type] = params[:report_type]
      session[:period] = period
      session[:period_year] = year

      session[:range] = LoanComplianceEvent.set_session_period(period, year, session[:report_type])
    else
      flash[:error] = 'Period and year must both be selected.'
    end

    redirect_to :back
  end

  def transform
    # begin
    if HmdaInvestorCode.investor_list.any?
      flash[:error] = 'Please update investor codes.'
      redirect_to :back
    else
      LoanComplianceEvent.do_transformations
      flash[:success] = 'Transformations processed successfully.'
      redirect_to :back
    end

    # rescue => e
    #   flash[:error] = e.message
    #   redirect_to :back
    # end

  end

  def import
    begin
      loan_upload = LoanComplianceEventUpload.new()

      loan_upload.user_uuid = current_user.uuid
      loan_upload.hmda_loans = params[:lar_file]

      period = params[:month]
      year = params[:year]

      loan_upload.add_periods(period, year)

      session[:report_type] = 'm'
      session[:period] = period
      session[:period_year] = year
      session[:range] = LoanComplianceEvent.set_session_period(period, year, session[:report_type])

      loan_upload.job_status = JobStatus::JobStatus.create!
      loan_upload.save!

      loan_upload.process_upload

      LoanComplianceEvent.unexported.update_all(changed_values: nil)

      flash[:success] = "File has been successfully added to processing queue."
      redirect_to action: :import_form, id: loan_upload.id
    rescue => e
      Rails.logger.error ExceptionFormatter.new(e)
      flash[:error] = e.message.split('~')
      redirect_to action: :import_form
    end

  end

  def export_form
  end

  def export
    events = LoanComplianceEvent.reportable_events_between(from, to)
    file_upload = events.last.try(:loan_compliance_event_upload)
    if file_upload
      file_upload.exported_at = Time.now
      file_upload.save
    end

    respond_to do |format|
      format.csv { render text: make_csv(events) }
    end
  end

  def undo_export
    events = LoanComplianceEvent.reportable_events_between(from, to)
    file_upload = events.last.try(:loan_compliance_event_upload)
    if file_upload
      file_upload.exported_at = nil
      file_upload.save
      flash[:success] = 'Loan Compliance Event unexport was successful'
    else
      flash[:error] = 'Failed to unexport Loan Compliance Event'
    end

    redirect_to action: :index
  end

  def edit
    @lce = LoanComplianceEvent.where(session[:range]).where(aplnno: params[:id]).last

    if !@lce
      flash[:error] = "Unable to find loan #{params[:id]}. Please enter a valid loan number."
      redirect_to action: :index
    end
  end

  def update
    @lce = LoanComplianceEvent.find params[:id]

    if @lce.update_attributes(update_params)
      @lce.last_updated_by = current_user.display_name
      if @lce.save
        flash[:success] = 'Loan Compliance Event was successfully updated.'
      else
        flash[:error] = @lce.errors.full_messages
      end
    else
      flash[:error] = @lce.errors.full_messages
    end
    render action: "edit"
  end

  def mass_update
    file = params[:update_file]
    if file.nil?
      flash[:error] = "Please specify a file to upload."
      redirect_to action: :update_form
      return
    end

    if params[:header].blank?
      flash[:error] = "Please specify a header name."
      redirect_to action: :update_form
      return
    end

    begin
      Compliance::Hmda::HmdaMassUpdate.new(file.read, params[:header]).mass_update
      flash[:success] = "Mass update successful."
      redirect_to action: :index
    rescue => e
      flash[:error] = e.message.split('~')
      redirect_to action: :update_form
    end
  end

  private


  def from
    @from ||= Date.strptime(params[:from], '%m/%d/%Y')
  end

  def to
    @to ||= Date.strptime(params[:to], '%m/%d/%Y')
  end

  def make_csv events
    CSV.generate do |csv|
      csv << LoanComplianceEvent::DICTIONARY.keys
      events.each do |e|
        e.tincome = 'NA' if e.tincome.to_s.eql?('0') && e.loan_prog.to_s.match(/Streamline|IRRL/)
        e.loan_term = (e.loan_term / 12) rescue ''
        e.initadjmos = (e.initadjmos / 12) rescue ''
        e.amorttype = (e.amorttype == 'F' ? '1' : '2') rescue ''
        csv << LoanComplianceEvent::DICTIONARY.values.map{ |symbol| e.public_send(symbol) }
      end
    end
  end

  def self.permitted_attributes
    blacklist = [ :id, :created_at, :updated_at, :reconciled_at, :reconciled_by, 
                  :original_signature, :current_signature, :last_updated_by, :changed_values ]
    LoanComplianceEvent::attribute_names.map(&:to_sym) - blacklist
  end

  private

  def update_params
    permitted_attrs = self.class.permitted_attributes
    params.require(:loan_compliance_event).permit(*permitted_attrs)
  end
end
