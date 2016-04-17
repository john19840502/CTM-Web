class LoanComplianceFilters::FaceToFaceFilter < LoanComplianceFilter

  def filter_query period, type
  	null_changed_values_column
    LoanComplianceEvent.for_period(period, type).where{ ((apptakenby == 'F') & ((apeth == 3) | (aprace1 == 6) | (aprace2 == 6) | (aprace3 == 6) | (aprace4 == 6) | (aprace5 == 6) |  (apsex == 3) | (capeth == 3) | (caprace1 == 6) | (caprace2 == 6) | (caprace3 == 6) | (caprace4 == 6) | (caprace5 == 6) | (capsex == 3))) & (reportable != false) }
  end

  def filter_columns
    %w(apptakenby appname apeth aprace1 aprace2 aprace3 aprace4 aprace5 apsex capeth caprace1 caprace2 caprace3 caprace4 caprace5 capsex last_updated_by)
  end

  def filter_title
    'HMDA Face-to-Face Loans Filter'
  end

end