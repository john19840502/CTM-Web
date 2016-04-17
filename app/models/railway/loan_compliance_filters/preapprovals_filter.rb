class LoanComplianceFilters::PreapprovalsFilter < LoanComplianceFilter

  def filter_query period, type
    null_changed_values_column
    LoanComplianceEvent.for_period(period, type).where{ (((propstreet.like '%TBD%') | (propcity.like '%TBD%') | 
      (propstate.like '%TBD%') | (propzip.like '%TBD%')) & ((preappr == 2) | (preappr == 3))) | 
      (((propstreet.not_like '%TBD%') | (propcity.not_like '%TBD%') | (propstate.not_like '%TBD%') | 
        (propzip.not_like '%TBD%')) & (preappr == 1)) & (reportable != false) }
  end

  def filter_columns
    %w(action_code preappr propstreet propcity propstate propzip last_updated_by)
  end

  def filter_title
    'HMDA Preapprovals Filter'
  end

  def filter_update columns, params
    filter_query.update_all(columns => params[columns])
  end

end