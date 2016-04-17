class LoanComplianceFilters::NonExistantLoansFilter < LoanComplianceFilter

  def filter_query period, type
  	null_changed_values_column
    LoanComplianceEvent.for_period(period, type).where{ (non_existant_loan == true && reportable == false) }
  end

  def filter_columns
    %w(comments last_updated_by)
  end

  def filter_title
    'HMDA Non-Reportable Loans Filter'
  end

end