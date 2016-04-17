class Funding::ChecklistsController < ApplicationController

  def index
  end

  def show
    @loan = fetch_loan
    raise "Loan not found or You are not allowed to view it" unless @loan
    @checklist = @loan.funding_checklist 

    @checklist = FundingChecklist.new({loan_num: @loan.loan_num}) if @checklist.nil?

    @thing = Funding::BuildChecklistQuestions.call @checklist
    render json: @thing, status: :ok

  rescue => e
    handle_json_error_response e
  end

  def create
    loan = fetch_loan
    raise "Loan not found or you are not allowed to view it." unless loan 
    @checklist = loan.funding_checklist 
    if @checklist.nil?
      @checklist = loan.create_funding_checklist!
      @checklist.created_by = current_user.uuid
      @checklist.save!
    end
    render nothing: true, status: :ok   

  rescue => e
    handle_json_error_response e
  end

  def update
    loan = fetch_loan
    raise "Loan not found or You are not allowed to view it" unless loan
    checklist = loan.funding_checklist
    unless checklist.present?
      render status: :not_found, json: { message: "Funding Checklist not found for loan #{params[:id]}" } and return
    end
    
    questions = params[:checklist][:questions]
    answers = checklist.checklist_answers

    questions.each do |question|
      if question[:answer].present?
        answer = answers.find_by(name: question[:attribute]) || answers.build({name: question[:attribute]}, without_protection: true)
        answer.answer = question[:answer]
        answer.save!
      end
    end

    if params[:button] == 'complete'
      checklist.completed = true
      checklist.completed_by = current_user.uuid
      checklist.save!
    end
    render nothing: true, status: :ok
  end

  private
  def fetch_loan
    Loan.find_by(loan_num: params[:id]) || TestLoan.find_by(loan_num: params[:id])
  end
end