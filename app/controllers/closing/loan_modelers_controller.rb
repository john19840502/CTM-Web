class Closing::LoanModelersController < ApplicationController
  # load_and_authorize_resource class: Loan

  def index
  end

  def search
    id = params[:loan_id]
    if id.present?
      loan = Loan.find_by_loan_num(id) || TestLoan.find_by_loan_num(id)
      if loan.try(:trid_loan?)
        redirect_to closing_loan_modeler_path(id, format: :html)
      else
        redirect_to closing_loan_modeler_pre_trid_path(id, format: :html)
      end
    else
      flash[:error] = "Loan ID missing"
      redirect_to closing_loan_modelers_path
    end
  end

  def show
    @loan = Loan.find_by_loan_num(params[:id]) || TestLoan.find_by_loan_num(params[:id])
    if @loan.nil? || !(can? :manage, Loan)
      flash[:error] = "Loan #{params[:id]} not found or you are not allowed to view it."
      redirect_to closing_loan_modelers_path and return
    else
      unless @loan.is_locked?
        flash[:error] = "Loan #{params[:id]} is not locked."
      end

      respond_to do |format|
        format.html
        format.pdf do
          render  :pdf          => "#{@loan.loan_num rescue 'UNKNOWN_LOAN'}_loan_modeler",
                  :disposition  => 'attachment',
                  :layout       => 'loan_modelers',
                  :show_as_html => false,
                  :greyscale    => false,
                  :dpi          => 600
        end # render pdf
      end # respond_to
    end # if
  end # show

  def submit
    loan = Loan.find_by_loan_num(params[:loan_id]) || TestLoan.find_by_loan_num(params[:loan_id])
    modeler = loan.dodd_frank_modeler || loan.build_dodd_frank_modeler

    modeler.update_from_params(params)

    render :nothing => true
  end

  def dodd_frank_misc_fee_remove
    misc_fee = DoddFrankModelerMiscOtherFee.find_by_id(params[:id])
    misc_fee.destroy unless misc_fee.nil?
    render nothing: true
  end

  def fund_submit
    loan = Loan.find_by_loan_num(params[:loan_id]) || TestLoan.find_by_loan_num(params[:loan_id])
    modeler = loan.funding_modeler || loan.build_funding_modeler

    modeler.update_from_params(params)

    render :nothing => true
  end

  def fredd_submit
    loan = Loan.find_by_loan_num(params[:loan_id]) || TestLoan.find_by_loan_num(params[:loan_id])
    modeler = loan.freddie_relief_modeler || loan.build_freddie_relief_modeler

    modeler.update_from_params(params)

    render :nothing => true
  end

  def broker_submit
    loan = Loan.find_by_loan_num(params[:loan_id]) || TestLoan.find_by_loan_num(params[:loan_id])
    modeler = loan.broker_comp_modeler || loan.build_broker_comp_modeler

    modeler.update_from_params(params)

    render :nothing => true
  end

end
