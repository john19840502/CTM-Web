class Compliance::Hmda::LoanComplianceExceptionsController < ApplicationController
  
  def index
  end

  def search 
    unless from && to && from2 && to2
      flash[:error] = "Date range fields cannot be blank."
      redirect_to action: :index
    end

    @diffs = lce.compare_periods

  end

  def reconcile
    lce.update_cra_wiz
    @aplno = params[:aplnno]
    respond_to do |format|
      format.js
    end
  end

  def lce
    LoanComplianceException.new(range, range2, params, current_user)
  end

  def range
    LoanComplianceEvent.where( actdate: from..to)
  end

  def range2
    LoanComplianceEvent.where( actdate: from2..to2)
  end

  def from
    @from ||= Date.strptime(params[:from], '%m/%d/%Y') rescue nil
  end

  def to
    @to ||= Date.strptime(params[:to], '%m/%d/%Y') rescue nil
  end

  def from2
    @from2 ||= Date.strptime(params[:from2], '%m/%d/%Y') rescue nil
  end

  def to2
    @to2 ||= Date.strptime(params[:to2], '%m/%d/%Y') rescue nil
  end

end