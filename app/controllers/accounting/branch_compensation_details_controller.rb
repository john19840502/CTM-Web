class Accounting::BranchCompensationDetailsController < RestrictedAccessController
  load_and_authorize_resource  class: BranchCompensationDetail

  def new
    @plan = BranchCompensation.where(id: params[:pid]).last
    @branch_compensation_detail = BranchCompensationDetail.new({branch_compensation_id: @plan.id}, without_protection: true)
  end

  def create
    @plan = BranchCompensation.where(id: params[:branch_compensation_detail][:branch_compensation_id]).last
    @branch_compensation_detail = BranchCompensationDetail.new(branch_compensation_detail_params, without_protection: true)

    respond_to do |format|
      if @branch_compensation_detail.save
        flash[:success] = 'Branch Compensation plan details was successfully added.'
        format.html { redirect_to accounting_branch_compensation_path(@plan) }
      else
        flash[:error] = @branch_compensation_detail.errors.full_messages
        format.html { render action: "new" }
      end
    end
  end

  def edit
    @branch_compensation_detail = BranchCompensationDetail.where(id: params[:id]).last
    @plan = @branch_compensation_detail.branch_compensation
  end

  def update
    @plan = BranchCompensation.where(id: params[:branch_compensation_detail][:branch_compensation_id]).last
    @branch_compensation_detail = BranchCompensationDetail.where(id: params[:id]).last

    respond_to do |format|
      if @branch_compensation_detail.update_attributes(branch_compensation_detail_params, without_protection: true)
        flash[:success] = 'Branch Compensation plan details was successfully updated.'
        format.html { redirect_to accounting_branch_compensation_path(@plan) }
      else
        flash[:error] = @branch_compensation_detail.errors.full_messages
        format.html { render action: "edit" }
      end
    end

  end

  def destroy
    @branch_compensation_detail = BranchCompensationDetail.where(id: params[:id]).last
    @branch_compensation_detail.destroy

    respond_to do |format|
      format.html { redirect_to accounting_branch_compensation_path(@branch_compensation_detail.branch_compensation_id) }
      format.json { head :no_content }
    end
  end

private
  def branch_compensation_detail_params
    params.require(:branch_compensation_detail).permit(:branch_compensation_id, :branch_revenue, :lo_traditional_split, :tiered_split_low, 
        :tiered_split_high, :tiered_amount, :effective_date, :branch_min, :branch_max, :lo_min, :lo_max)
  end

end
