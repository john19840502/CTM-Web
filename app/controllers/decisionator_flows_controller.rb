class DecisionatorFlowsController < ApplicationController
  def validations
    if @loan = Loan.find_by_id(params[:id]) || TestLoan.find_by_id(params[:id])
      
      fact_types = Decisions::Facttype.new(params[:flow], {loan: @loan}).execute
      @response  = Decisions::Flow.new(params[:flow], fact_types).execute

      @response[:errors] = AppendValidationWarningHistory.call @response[:errors], @loan.id
      @response[:warnings] = AppendValidationWarningHistory.call @response[:warnings], @loan.id

      Bpm::StatsRecorder.new.record_validation_event(params[:flow], params[:event_id], @response, fact_types)
    end  

    respond_to do |format|
      format.json {render :json => @response.as_json}
    end
  end

  def create_new_event
    @loan = Loan.find_by_id(params[:id]) || TestLoan.find_by_id(params[:id])
    event = Bpm::StatsRecorder.new.create_new_event(@loan, current_user, params[:validation_type])
    respond_to do |format|
      format.json { render :json => event.as_json }
    end
  end
end

