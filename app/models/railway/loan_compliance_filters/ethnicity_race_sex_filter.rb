class LoanComplianceFilters::EthnicityRaceSexFilter < LoanComplianceFilter

  def filter_query period, type
  	null_changed_values_column
    LoanComplianceEvent.for_period(period, type).where{ (((apeth == 4) | (aprace1 == 7) | (aprace2 == 7) | (aprace3 == 7) | (aprace4 == 7) | (aprace5 == 7) |  (apsex == 4) | (capeth == 4) | (caprace1 == 7) | (caprace2 == 7) | (caprace3 == 7) | (caprace4 == 7) | (caprace5 == 7) | (capsex == 4))) & (reportable != false) }
  end

  def filter_columns
    %w(appname apeth aprace1 aprace2 aprace3 aprace4 aprace5 apsex capeth caprace1 caprace2 caprace3 caprace4 caprace5 capsex last_updated_by)
  end

  def filter_title
    'HMDA Ethnicity, Race, Sex Filter'
  end

end