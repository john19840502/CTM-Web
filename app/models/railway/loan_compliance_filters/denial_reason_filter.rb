class LoanComplianceFilters::DenialReasonFilter < LoanComplianceFilter

  def filter_query period, type
    null_changed_values_column
    LoanComplianceEvent.for_period(period, type).where{ 
    (
      (
        (action_code.not_in [3, 7]) & ((denialr1 != nil) | (denialr2 != nil) | (denialr3 != nil))
      ) | 

      (
        (action_code.in [3, 7]) & ((denialr1 == nil) & (denialr2 == nil) & (denialr3 == nil))
      ) |

      (
        (denialr1 != nil) & ((denialr1 == denialr2) | (denialr1 == denialr3)) 
      ) |
       
      (
        (denialr2 != nil) & (denialr2 == denialr3) 
      )
    ) & (reportable != false)}

  end

  def filter_columns
    %w(action_code denialr1 denialr2 denialr3 appname apdate propstreet propcity propstate propzip last_updated_by)
  end

  def filter_title
    'HMDA Denial Reason Filter'
  end

end