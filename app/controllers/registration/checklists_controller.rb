class Registration::ChecklistsController < RestrictedAccessController

  def show
    loan = fetch_loan
    raise "loan not found or you are not allowed to see it" unless loan

    unless loan.trid_loan?
      render status: 500, json: { message: 'Non TRID loans should not have a checklist' } and return
    end

    thing = Validation::Checklist::BuildChecklistResponse.call RegistrationChecklistDefinition.new(loan.registration_checklist)
    render json: thing, status: :ok
 
    rescue => e
      handle_json_error_response e
  end

  def create
    loan = fetch_loan
    raise "loan not found or you are not allowed to see it" unless loan

    raise "there is already a checklist for this loan" unless loan.registration_checklist.nil?

    loan.create_registration_checklist!

    thing = Validation::Checklist::BuildChecklistResponse.call RegistrationChecklistDefinition.new(loan.registration_checklist)
    render json: thing, status: :ok

    rescue => e
      handle_json_error_response e
  end

  def update
    loan = fetch_loan
    raise "loan not found or you are not allowed to see it" unless loan

    unless loan.registration_checklist.present?
      render status: :not_found, json: { message: "Checklist not found for loan #{params[:id]}" } and return
    end

    answers = loan.registration_checklist.checklist_answers
    answer = answers.find_by(name: params[:name]) || answers.build({name: params[:name]}, without_protection: true)
    answer.answer = params[:answer]
    answer.save!

    render nothing: true, status: :ok
    rescue => e
      handle_json_error_response e
  end

  private

  def fetch_loan
    Loan.find_by(loan_num: params[:id]) || TestLoan.find_by(loan_num: params[:id])
  end

end
