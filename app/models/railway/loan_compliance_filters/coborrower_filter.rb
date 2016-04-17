class LoanComplianceFilters::CoborrowerFilter < LoanComplianceFilter

  def filter_query period, type
  	null_changed_values_column
    LoanComplianceEvent.for_period(period, type).
      joins{ loan_general.borrowers }.
      where{ loan_general.borrowers.borrower_id.not_eq('BRW1') }.
      where{ (capeth == 5) | (caprace1 == 8) | (capsex == 5) }.
      where{ (reportable != false) }
  end

  def filter_columns
    %w(appname apptakenby capeth caprace1 caprace2 caprace3 caprace4 caprace5 capsex last_updated_by)
  end

  def filter_title
    'HMDA Co-borrower Filter'
  end
  
end