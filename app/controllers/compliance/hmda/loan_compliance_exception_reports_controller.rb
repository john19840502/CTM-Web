class Compliance::Hmda::LoanComplianceExceptionReportsController < RestrictedAccessController
  # load_and_authorize_resource
  active_scaffold LoanComplianceExceptionReport do |config|
    config.label = 'Loan Compliance Exception Report'

    config.action_links.add :build_report, type: :collection, position: :top,
        label: 'Generate Report', page: true, refresh_on_close: true,
        ignore_method: :hide_create_link?

    config.list.columns = [:id, :name, :job_status, :created_at, :bundle]
    config.list.sorting = [{ :id => :desc }]

    config.columns[:bundle].label = 'Report Links'
    config.actions.exclude :create
    config.actions.exclude :show
    config.actions.exclude :new
    config.actions.exclude :edit
    config.actions.exclude :delete
    config.actions.exclude :update

    config.columns[:job_status].label = 'Status'
    config.columns[:job_status].css_class = "as-job-status-container"

  end


  def build_report
    flash[:info] = 'Report has been queued for processing.'
    # the report needs start_date / end_date, so its input here
    # due to inheritance only
    report = LoanComplianceExceptionReport.create(
      start_date: Date.today,
      end_date: Date.today)
    respond_to do |format|
      format.html { redirect_to :action => :index }
    end
  end
end
