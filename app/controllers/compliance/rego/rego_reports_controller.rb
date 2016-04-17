class Compliance::Rego::RegoReportsController < RestrictedAccessController
  load_and_authorize_resource  



  active_scaffold :rego_report do |config|
    config.label = 'Reg O and Related Parties Reports'

    config.list.columns = [:id, :name, :job_status, :created_at, :bundle]
    config.list.sorting = [{ :id => :desc }]
    config.update.columns = [:name, :start_date, :end_date, :status, :bundle]

    config.columns[:bundle].label = 'Report Links'
    config.columns[:job_status].label = 'Status'
    config.columns[:job_status].css_class = "as-job-status-container"

    config.actions.exclude :update, :delete, :show, :create, :new, :edit
  end
end
 
