class LoanComplianceFilters::AdjustmentPeriodFilter < LoanComplianceFilter

  def filter_query period, type
  	null_changed_values_column
    i = [60, 84, 36]
    LoanComplianceEvent.for_period(period, type).where{ (amorttype == 'A') & ((initadjmos == nil) | (initadjmos << i)) & (reportable != false) }
  end

  def filter_columns
    %w(amorttype initadjmos last_updated_by)
  end

  def filter_title
    'HMDA Adjustment Period Filter'
  end
end