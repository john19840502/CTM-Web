class LoanComplianceEventsController < ApplicationController  
  def update
    lce = LoanComplianceEvent.find params[:id]

    lce.update_attributes(update_params, without_protection: true)
    lce.last_updated_by = current_user.display_name
    lce.save!
    respond_with_bip(lce)
  end

  private

  def update_params
    attrs = Compliance::Hmda::LoanComplianceEventsController.permitted_attributes
    params.require(:loan_compliance_event).permit(*attrs)
  end
end
