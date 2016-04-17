class Accounting::BranchEmployeeOtherCompensationsController < RestrictedAccessController
  load_and_authorize_resource class: BranchEmployeeOtherCompensation

  # def index
  #   if params[:pid]
  #     @plan = BranchCompensation.where(id: params[:pid]).last
  #     @employees = @plan.branch.employees - @plan.employees
  #   end
  # end

  def new
    @branch_employee_other_compensation = BranchEmployeeOtherCompensation.new({datamart_user_id: params[:uid], institution_id: params[:bid]}, without_protection: true)
  end

  def create
    @branch_employee_other_compensation = BranchEmployeeOtherCompensation.new(branch_employee_other_compensation_params, without_protection: true)

    respond_to do |format|
      if @branch_employee_other_compensation.save

        flash[:success] = 'Loan Officer was successfully updated.'
        format.html { redirect_to core_originator_path(@branch_employee_other_compensation.datamart_user_id) }
        format.json { render json: @branch_employee_other_compensation, status: :created, location: @branch_employee_other_compensation }
      else
        flash[:error] = @branch_employee_other_compensation.errors.full_messages
        format.html { render action: "new" }
        format.json { render json: @branch_employee_other_compensation.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @branch_employee_other_compensation = BranchEmployeeOtherCompensation.where(id: params[:id]).last
  end

  def update
    @branch_employee_other_compensation = BranchEmployeeOtherCompensation.where(id: params[:id]).last

    respond_to do |format|
      if @branch_employee_other_compensation.update_attributes(branch_employee_other_compensation_params, without_protection: true)
        flash[:success] = 'Loan Officer was successfully updated.'
        format.html { redirect_to core_originator_path(@branch_employee_other_compensation.datamart_user_id) }
        format.json { render json: @branch_employee_other_compensation, status: :created, location: @branch_employee_other_compensation }
      else
        flash[:error] = @branch_employee_other_compensation.errors.full_messages
        format.html { render action: "edit" }
        format.json { render json: @branch_employee_other_compensation.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @branch_employee_other_compensation = BranchEmployeeOtherCompensation.find(params[:id])
    @branch_employee_other_compensation.destroy

    respond_to do |format|
      format.html { redirect_to core_originator_path(@branch_employee_other_compensation.datamart_user_id) }
      format.json { head :no_content }
    end
  end

private
  def branch_employee_other_compensation_params
    params.require(:branch_employee_other_compensation).permit(:datamart_user_id, :institution_id, :effective_date, :bsm_override, :per_loan_processed, :per_loan_branch_processed, :institution_id, :bmsf_override)
  end

end