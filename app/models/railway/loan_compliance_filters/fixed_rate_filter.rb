class LoanComplianceFilters::FixedRateFilter < LoanComplianceFilter

  def filter_query period, type
  	null_changed_values_column
    terms = [360, 300, 240, 180, 120]
    LoanComplianceEvent.for_period(period, type).where{ (amorttype == 'F') & (initadjmos != nil) & (loan_term << terms) & (reportable != false) }
  end

  def filter_columns
    %w(amorttype loan_prog initadjmos loan_term last_updated_by)
  end

  def filter_title
    'HMDA Fixed Rate Filter'
  end

end