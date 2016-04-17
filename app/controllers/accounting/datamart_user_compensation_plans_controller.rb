class Accounting::DatamartUserCompensationPlansController < RestrictedAccessController
  load_and_authorize_resource class: DatamartUserCompensationPlan

  def index
    if params[:pid]
      @plan = BranchCompensation.where(id: params[:pid]).last
      @employees = @plan.branch.employees - @plan.employees
    end
  end

  def new
    if params[:pid]
      @plan = BranchCompensation.where(id: params[:pid]).last
      @employees = @plan.branch.employees.active - @plan.employees
      @datamart_user_compensation_plan = DatamartUserCompensationPlan.new({branch_compensation_id: @plan.id}, without_protection: true)
    elsif params[:bid]
      @datamart_user_compensation_plan = DatamartUserCompensationPlan.new({datamart_user_id: params[:eid]}, without_protection: true)

      @plans = BranchCompensation.where(institution_id: params[:bid]) - 
        [@datamart_user_compensation_plan.employee.current_compensation_details_for_branch(params[:bid]).try(:branch_compensation)]
      

      if @plans.empty?
        flash[:error] = 'No other plans are currently available.'
        redirect_to core_originator_path(@datamart_user_compensation_plan.datamart_user_id)
      else
        render action: "new_plans"
      end
    end
  end

  def create
    @datamart_user_compensation_plan = DatamartUserCompensationPlan.new(datamart_user_compensation_plan_params, without_protection: true)

    respond_to do |format|
      if @datamart_user_compensation_plan.save
        flash[:success] = 'Loan Officer was successfully added to the plan.'
        if params[:bid].blank?
          format.html { redirect_to accounting_branch_compensation_path(@datamart_user_compensation_plan.branch_compensation_id) }
        else
          format.html { redirect_to core_originator_path(@datamart_user_compensation_plan.datamart_user_id) }
        end
        format.json { render json: @plan, status: :created, location: @plan }
      else
        flash[:error] = @datamart_user_compensation_plan.errors.full_messages
        if params[:bid].blank?
          @plan = BranchCompensation.where(id: params[:datamart_user_compensation_plan][:branch_compensation_id]).last
          @employees = @plan.branch.employees.active - @plan.employees
          format.html { render action: "new" }
        else
          @plans = BranchCompensation.where(institution_id: params[:bid]) - 
            [@datamart_user_compensation_plan.employee.current_compensation_details_for_branch(params[:bid]).try(:branch_compensation)]
          format.html { render action: "new_plans" }
        end

        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @datamart_user_compensation_plan = DatamartUserCompensationPlan.where(id: params[:id]).last
  end

  def update
    @datamart_user_compensation_plan = DatamartUserCompensationPlan.where(id: params[:id]).last
    
    respond_to do |format|
      if @datamart_user_compensation_plan.update_attributes(datamart_user_compensation_plan_params, without_protection: true)
        flash[:success] = 'Compensation plan assignment was successfully updated.'
        format.html { redirect_to accounting_branch_compensation_path(@datamart_user_compensation_plan.branch_compensation_id) }
        format.json { render json: @plan, status: :created, location: @plan }
      else
        flash[:error] = @datamart_user_compensation_plan.errors.full_messages
        format.html { render action: "edit" }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @datamart_user_compensation_plan = DatamartUserCompensationPlan.find(params[:id])
    @datamart_user_compensation_plan.destroy

    respond_to do |format|
      format.html { redirect_to core_originator_path(@datamart_user_compensation_plan.datamart_user_id) }
      format.json { head :no_content }
    end
  end

private
  def datamart_user_compensation_plan_params
    params.require(:datamart_user_compensation_plan).permit(:datamart_user_id, :effective_date, :branch_compensation_id)
  end

end
