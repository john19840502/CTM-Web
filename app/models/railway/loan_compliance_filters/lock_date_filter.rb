class LoanComplianceFilters::LockDateFilter < LoanComplianceFilter

  def filter_query period, type
  	null_changed_values_column
    LoanComplianceEvent.for_period(period, type).where{ (lockdate > actdate) & (reportable != false) }
  end

  def filter_columns
    %w(lockdate last_updated_by)
  end

  def filter_title
    'HMDA Lock Date > Action Date Filter'
  end

end