class LoanComplianceFilters::ApplicationDateFilter < LoanComplianceFilter

  def filter_query period, type
  	null_changed_values_column
    LoanComplianceEvent.for_period(period, type).where{ (apdate > actdate) & (reportable != false) }
  end

  def filter_columns
    %w(apdate actdate last_updated_by)
  end

  def filter_title
    'Application Date > Action Date Filter'
  end

end