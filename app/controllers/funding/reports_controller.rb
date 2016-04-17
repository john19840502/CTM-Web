class Funding::ReportsController < RestrictedAccessController

  def index
  end

  def report
    @checklists = FundingChecklist.between_dates(start_date, end_date)
    render status: :ok, json: build_output(@checklists)
  end

  def comparision
    @checklists = FundingChecklist.between_dates(start_date, end_date)
    respond_to do |format|
      format.html
      format.json { render status: :ok, json: build_funder_compare(@checklists) }
    end
  end

  private

  def build_funder_compare input
    @report_data = []
    input.each do |data|
      @each_data = {loan_number: data.loan_num, mortgagebot_assigned_funder: data.try!(:funding_data).try!(:funder_name), ctmweb_funder_name: data.created_by_user_name}
      @report_data.push @each_data
    end
    @checklist_prompts = ['Loan Number', 'MortgageBot Assigned Funder Name', 'CTMWEB Assigned Funder Name']
    @output_data = { prompts: @checklist_prompts , checklist_data: @report_data}
  end

  def start_date
    undefined(params[:start_date]) ? Date.today.beginning_of_month : params[:start_date].to_date
  end

  def end_date
    undefined(params[:end_date]) ? Date.today : params[:end_date].to_date
  end

  def undefined input
    input.in?(['undefined', nil, 'null', ''])
  end

  def build_output input
    @report_data = []
    input.each do |data|
      @each_data = {loan_number: data.loan_num, subject_state_property: data.loan.property_state, loan_purpose: data.loan.loan_type, ctmweb_funder_name: data.created_by_user_name, ctmweb_completion_funder_name: data.completed_by_user_name, checklist_start_date: data.created_at.to_date, checklist_completion_date: data.completion_date, elapsed_time: data.elapsed_time}
      @each_data.merge!(refined_questions(Funding::BuildChecklistQuestions.call data))

      @report_data.push @each_data
    end
    @output_data = { prompts: checklist_prompts , checklist_data: @report_data}
    @output_data
  end

  def checklist_prompts
    prompts_array = ["Loan Number", "Subject Property State", "Loan Purpose", "CTMWEB Assigned Funder Name", "CTMWEB Completion Funder Name", "Checklist Start Date", "Checklist Completion Date", "Elapsed Completion Time"]
    questions_array = Funding::BuildChecklistQuestions.call FundingChecklist.new
    prompts_array << questions_array[:questions].map{|q| q[:prompt]}
    prompts_array.flatten
  end

  def refined_questions checklist_question
    chk = checklist_question[:questions].each {|p| p.delete(:prompt)}
    Hash[chk.map(&:values)]
  end
end