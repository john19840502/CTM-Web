class LoanComplianceFilters::IncomeFilter < LoanComplianceFilter

  def filter_query period, type
    null_changed_values_column
    LoanComplianceEvent.for_period(period, type).where{ (reportable != false) &
                                (employee_loan == true) | 
                                (((tincome == 'NA') | (tincome != 0)) & ((loan_prog =~ '%Streamline%') | (loan_prog =~ '%IRRL%'))) | 
                                (((tincome == 'NA') | (tincome <= 0)) & ((loan_prog !~ '%IRRL%') & (loan_prog !~ '%Streamline%') & (employee_loan == false))) 
                              }
  end

  def filter_columns
    %w(tincome employee_loan loan_prog last_updated_by)
  end

  def filter_title
    'HMDA Income Filter'
  end

end