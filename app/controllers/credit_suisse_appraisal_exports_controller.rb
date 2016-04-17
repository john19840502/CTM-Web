class CreditSuisseAppraisalExportsController < ApplicationController
  def index
    @title = model.to_s.titleize.presence
  end

  def search
    id = params[:id]
    if id.present?
      redirect_to credit_suisse_appraisal_export_path(id)
    else
      flash[:error] = "Loan ID missing or you are not allowed to view it."
      redirect_to credit_suisse_appraisal_exports_path
    end
  end

  def show
    data.label = model.to_s.titleize
    seller = model.by_loan_id(params[:id])
    if seller.none?
      flash[:error] = "Loan #{params[:id]} not found."
      redirect_to credit_suisse_appraisal_exports_path and return
    end

    @first = seller.first
    flash[:error] = "The suggested investor for this loan is not Credit Suisse. Are you sure you want to proceed?" unless @first.credit_suisse_loan?
    data.model = seller
    data.columns = model.data_columns
    modified_records = data.record_list
    data.records = modified_records
    respond_to do |format|
      format.html
      format.xls { send_data data.to_xls }
    end
  end

  def model
    CreditSuisseAppraisalFile
  end
end
