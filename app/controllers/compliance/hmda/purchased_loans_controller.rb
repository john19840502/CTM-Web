require_or_load 'purchased_loan_importer'

class Compliance::Hmda::PurchasedLoansController < ApplicationController
  def index
    @title = "Purchased Loans"
  end

  def search
    report_date = params[:dispdate]

    if report_date.present?
      purchased_loan_date = model.where(dispdate: report_date)

      unless purchased_loan_date.any?
        flash[:error] = "Loan with disbursement date #{params[:dispdate]} not found."
        redirect_to compliance_hmda_purchased_loans_path and return
      end

      data.model = purchased_loan_date
      data.columns = data.model.column_names - ['original_signature', 'current_signature']
      data.default_order = "cpi_number"
      modified_records = data.record_list
      data.records = modified_records

      respond_to do |format|
        format.html
        format.json { render json: data.as_json(params) }
        format.xls { send_data data.to_xls }
      end

    else
      flash[:error] = "Disbursement Date missing or you are not allowed to view it."
      redirect_to compliance_hmda_purchased_loans_path
    end
  end

  def import_form
  end

  def import
    file = params[:purchased_loan_file]
    report_date = params[:dispdate]
    if file.nil?
      flash[:error] = "Please specify a file to upload"
      redirect_to action: :import_form
      return
    end
    
    begin
      Compliance::Hmda::PurchasedLoanImporter.new.import_file(file.read, report_date)
      flash[:success] = "Purchased Loans upload successful."
      redirect_to action: :index
    rescue => e
      flash[:error] = e.message.split('~')
      redirect_to action: :import_form
    end
  end

  def model
    PurchasedLoan
  end

end