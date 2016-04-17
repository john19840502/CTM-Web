class LoanComplianceFilters::HoepaFilter < LoanComplianceFilter

  def filter_query period, type
  	null_changed_values_column
    LoanComplianceEvent.for_period(period, type).where{ (hoepa == 1) & (reportable != false) }
  end

  def filter_columns
    %w(apr hoepa lockdate loan_prog last_updated_by)
  end

  def filter_title
    'HMDA HOEPA Filter'
  end

end