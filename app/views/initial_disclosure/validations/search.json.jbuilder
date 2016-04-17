json.loan do
  json.partial! 'shared/search_loan_details' , loan: @loan
  json.partial! 'shared/search_borrowers_information', loan: @loan

  json.manual_fact_types @manual_fact_types
end
