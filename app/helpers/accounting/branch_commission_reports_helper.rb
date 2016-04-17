module Accounting::BranchCommissionReportsHelper

  def status_name job_status
    job_status.present? ? job_status.status.capitalize : 'Unknown'
  end

end
