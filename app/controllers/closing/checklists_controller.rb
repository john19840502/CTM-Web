class Closing::ChecklistsController < RestrictedAccessController

  def show
    loan = fetch_loan
    raise "loan not found or you are not allowed to see it" unless loan

    thing = Validation::Checklist::BuildChecklistResponse.call ClosingChecklistDefinition.new(loan.closing_checklist)

    respond_to do |format|
      format.json do 
        render :json    => thing, 
               :status  => :ok 
      end
      format.pdf do
        @loan_data = thing
        @loan_id = loan.loan_num
        render :pdf          => "#{loan.loan_num rescue 'UNKNOWN_LOAN'}_loan_closing_checklist",
               :disposition  => 'attachment',
               :layout       => 'checklists',
               :show_as_html => false,
               :greyscale    => false,
               :dpi          => 600
      end 
      format.all do
        render :json    => thing, 
               :status  => :ok 
      end
    end
  rescue => e
    handle_json_error_response e if formats.first == :json || formats.first == :html
  end

  def create
    loan = fetch_loan
    raise "loan not found or you are not allowed to see it" unless loan

    raise "there is already a checklist for this loan" unless loan.closing_checklist.nil?

    loan.create_closing_checklist!

    thing = Validation::Checklist::BuildChecklistResponse.call ClosingChecklistDefinition.new(loan.closing_checklist)
    render json: thing, status: :ok

  rescue => e
    handle_json_error_response e
  end

  def update
    loan = fetch_loan
    raise "loan not found or you are not allowed to see it" unless loan

    unless loan.closing_checklist.present?
      render status: :not_found, json: {message: "Checklist not found for loan #{params[:id]}"} and return
    end

    answers = loan.closing_checklist.checklist_answers
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
