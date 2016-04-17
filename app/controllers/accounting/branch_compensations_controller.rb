class Accounting::BranchCompensationsController < RestrictedAccessController
    
  load_and_authorize_resource class: BranchCompensation

  def index
    #only want to see Affiliate Standard loans (not wholesale or reimbursement)
    if params[:bid]
      @institution = Institution.where(id: params[:bid]).last
      # @plans = @institution.branch_compensation #.not_terminated
    else
      @branch_compensations = BranchCompensation.not_terminated
    end
  end

  def show
    @plan = BranchCompensation.where(id: params[:id]).last
  end

  def new
    @plan = BranchCompensation.new({institution_id: params[:bid]}, without_protection: true)
    @plan.branch_compensation_details << BranchCompensationDetail.new
  end

  def create
    @plan = BranchCompensation.new(branch_compensation_params, without_protection: true)

    respond_to do |format|
      if @plan.save
        flash[:success] = 'Branch Compensation plan was successfully added.'
        format.html { redirect_to accounting_branch_compensation_path(@plan) }
        format.json { render json: @plan, status: :created, location: @plan }
      else
        flash[:error] = @plan.errors.full_messages
        format.html { render action: "new" }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @plan = BranchCompensation.where(id: params[:id]).last
  end

  def update
    @plan = BranchCompensation.where(id: params[:id]).last

    respond_to do |format|
      if @plan.update_attributes(branch_compensation_params, without_protection: true)
        flash[:success] = 'Branch Compensation plan was successfully updated.'
        format.html { redirect_to accounting_branch_compensation_path(@plan) }
        format.json { render json: @plan, status: :created, location: @plan }
      else
        flash[:error] = @plan.errors.full_messages
        format.html { render action: "edit" }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

private
  def branch_compensation_params
    params.require(:branch_compensation).permit(:institution_id, :name, :termination_date, 
      branch_compensation_details_attributes: [:branch_compensation_id, :branch_revenue, :lo_traditional_split, :tiered_split_low, 
        :tiered_split_high, :tiered_amount, :effective_date, :branch_min, :branch_max, :lo_min, :lo_max]
    )
  end

end
