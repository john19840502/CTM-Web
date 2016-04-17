class Compliance::Hmda::DataChangeReportsController < ApplicationController

  def index
    @changes = Mdb::LoanComplianceEventAudit.in(loan_num: LoanComplianceEvent.unexported.map(&:aplnno)).page params[:page]
  end

  def search
    @changes = Mdb::LoanComplianceEventAudit

    if params[:loan_num].present? or params[:from].present? or params[:to].present?
      @changes = @changes.where(loan_num: params[:loan_num]) if params[:loan_num].present?
      # where('loan_compliance_event_changes.changed_column' => 'apr').

      if params[:from].present? 
        @changes = @changes.where('loan_compliance_event_changes.changed_at' => {'$gt' => params[:from].to_date}) rescue nil
      end

      if params[:to].present?
        @changes = @changes.where('loan_compliance_event_changes.changed_at' => {'$lt' => params[:to].to_date}) rescue nil
      end
    else
      @changes = Mdb::LoanComplianceEventAudit.in(loan_num: LoanComplianceEvent.unexported.map(&:aplnno))
    end  

    @changes = @changes.page params[:page]

    respond_to do |format|
      format.html { render :index }
      format.xls  { 
        headers["Content-Disposition"] = "attachment; filename=\"DataChangeReport-#{Time.now}.xls\""
        render :index 
      }
    end
  end
end