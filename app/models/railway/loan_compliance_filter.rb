class LoanComplianceFilter

  def self.find filter_number
    case filter_number
    when "1" then LoanComplianceFilters::PreapprovalsFilter.new;
    when "2" then LoanComplianceFilters::FaceToFaceFilter.new;
    when "3" then LoanComplianceFilters::LockDateFilter.new;
    when "4" then LoanComplianceFilters::DenialReasonFilter.new;
    when "6" then LoanComplianceFilters::EthnicityRaceSexFilter.new;
    when "7" then LoanComplianceFilters::ApplicationDateFilter.new;
    when "8" then LoanComplianceFilters::HoepaFilter.new;
    when "9" then LoanComplianceFilters::FixedRateFilter.new;
    when "10" then LoanComplianceFilters::AdjustmentPeriodFilter.new;
    when "11" then LoanComplianceFilters::CoborrowerFilter.new;
    when "12" then LoanComplianceFilters::MissingCoborrowerFilter.new;
    when "13" then LoanComplianceFilters::MissingFieldsFilter.new;
    when "14" then LoanComplianceFilters::IncomeFilter.new;
    when "15" then LoanComplianceFilters::NonExistantLoansFilter.new;
    else self.new
    end
  end

  def filter_query period, type
    LoanComplianceEvent.limit(0)
  end

  def filter_columns
    []
  end

  def filter_title
    'HMDA Filters'
  end

  def null_changed_values_column
    LoanComplianceEvent.unexported.update_all(changed_values: nil )
  end

  FILTER_NAME_AND_VALUE = [
    ['Preapprovals', 1],
    ['Face-to-Face Loans', 2],
    ['Lock Date > Action Date', 3],
    ['Denial Reason', 4],
    ['Ethnicity, Race, Sex', 6],
    ['Application Date > Action Date', 7],
    ['HOEPA', 8],
    ['Fixed Rate', 9],
    ['Adjustment Period', 10],
    ['Co-borrower', 11],
    ['Missing Co-borrower', 12],
    ['Missing Fields', 13],
    ['Income', 14],
    ['Non-Reportable Loans', 15]
  ]
end
