json.loan do
  json.partial! 'shared/search_loan_details' , loan: @loan
  json.partial! 'shared/search_borrowers_information', loan: @loan
  json.partial! 'shared/search_property_information' , loan: @loan
  json.partial! 'shared/search_loan_information' , loan: @loan
  json.partial! 'shared/collect_manual_fact_types', loan: @loan
  json.manual_fact_types @manual_fact_types

  json.underwriter @loan.latest_underwriter
end
