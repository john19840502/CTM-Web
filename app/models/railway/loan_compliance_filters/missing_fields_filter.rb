class LoanComplianceFilters::MissingFieldsFilter < LoanComplianceFilter

  def filter_query period, type
    null_changed_values_column
    LoanComplianceEvent.for_period(period, type).where(sql)
  end

  def filter_columns
    COLUMNS.map{|column| column.to_s}
  end

  def filter_title
    'HMDA Missing Fields Filter'
  end

  def sql
    sql = COLUMNS.map{|column| "#{column.to_s} IS NULL"}.join(' OR ')
    sql = "(#{sql}) AND reportable != 0"
    sql
  end

  COLUMNS = [
    :appname,
    :propstreet,
    :propcity,
    :propstate,
    :propzip,
    :apdate,
    :lntype,
    :proptype,
    :lnpurpose,
    :occupancy,
    :apeth,
    :capeth ,
    :aprace1,
    :caprace1,
    :apsex,
    :capsex,
    :apr,
    :loan_term,
    :apptakenby,
    :amort_term,
    :action_code 
  ]

end