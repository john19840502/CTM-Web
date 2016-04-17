class Accounting::BranchCommissionReportsController < RestrictedAccessController
  load_and_authorize_resource

  def index
    @reports = BranchCommissionReport.order("created_at desc").page(params[:page]).per(10)
  end

  def new
    @branch_commission_report = BranchCommissionReport.new()
  end

  def create
    @branch_commission_report = BranchCommissionReport.new(branch_commission_report_params, without_protection: true)

    respond_to do |format|
      if @branch_commission_report.save
        flash[:success] = 'New Branch Commission Report was successfully scheduled.'
        format.html { redirect_to accounting_branch_commission_reports_path }
        format.json { render json: @branch_commission_report, status: :created, location: @branch_commission_report }
      else
        flash[:error] = @branch_commission_report.errors.full_messages
        format.html { render action: "new" }
        format.json { render json: @branch_commission_report.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @branch_commission_report = BranchCommissionReport.find(params[:id])
    @branch_commission_report.destroy

    respond_to do |format|
      format.html { redirect_to accounting_branch_commission_reports_path }
      format.json { head :no_content }
    end
  end

private
  def branch_commission_report_params
    params.require(:branch_commission_report).permit(:report_month, :report_year, :report_period)
  end

end
