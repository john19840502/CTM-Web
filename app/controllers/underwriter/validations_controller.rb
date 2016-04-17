require 'bpm/stats_recorder'

class Underwriter::ValidationsController < RestrictedAccessController
  def index
  end

  def search
    @loan = Loan.find_by(loan_num: params[:id]) || TestLoan.find_by(loan_num: params[:id])

    if @loan.nil? || !@loan.can_see_loan?(current_user)
      respond_to do |format|
        format.json { render :json => { error: 'Loan not found', success: false}, status: :not_found }
        format.html { redirect_to underwriter_validations_path }
      end
    else
      ft_names = @loan.trid_loan? ? [ "E Consent Indicator" ] : []
      ft_names += [ "Type of Veteran", "VA Homebuyer Usage Indicator" ] if @loan.is_va?
      @manual_fact_types = ManualFactType.build_form_definitions(@loan, ft_names)

      @loan.save_last_underwriter_access(session[:cas_extra_attributes] && session[:cas_extra_attributes][:displayName])
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to underwriter_validations_path }
    end
  end

  def process_validations
    loan = Loan.find_by_id(params[:id]) || TestLoan.find_by_id(params[:id])
    raise "Could not find loan with id #{params[:id]}" unless loan
    results = Validation::Underwriter::do_checks(loan, current_user)
    Bpm::StatsRecorder.new.record_underwriter_validation_event(results, params[:event_id])
    render json: results

  rescue => e
    Rails.logger.error ExceptionFormatter.new(e)
    Airbrake.notify e
    render status: 500, json: { message: e.message, stacktrace: e.backtrace }
  end
end
