class Admin::LoanValidationsController < RestrictedAccessController

  def index
    @loan_validated_time = Bpm::LoanValidationEvent.where(validated_by_id: nil).last.created_at + Time.zone_offset('EST')
    @loans_validated = Bpm::LoanValidationEvent.where(validated_by_id: nil).where('created_at > ?', Time.now.beginning_of_day).count
  end

  def create
    begin
      Decisions::Validator.validate_loans
      Email::Postman.call Notifier.nightly_run_validation_job
      redirect_to admin_loan_validations_path, notice: 'Loan Validations successfully ended.'
    rescue Exception => e
      Airbrake.notify(e)
      Email::Postman.call Notifier.nightly_run_validation_failure(e.message)
      redirect_to admin_loan_validations_path, notice: 'FAILED to complete validations.'
    end
  end
end
